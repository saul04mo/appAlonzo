/**
 * ══════════════════════════════════════════════════════════
 * ALONZO — Cloud Functions for Firebase
 * ══════════════════════════════════════════════════════════
 * 
 * Server-side validation for orders. This is the ultimate
 * security layer — even if someone bypasses the app's
 * client-side validation, this function will catch it.
 * 
 * SETUP:
 * 1. Enable Firebase Blaze plan
 * 2. cd functions
 * 3. npm install
 * 4. firebase deploy --only functions
 * 
 * WHAT IT DOES:
 * - Triggers on every new invoice created in Firestore
 * - Reads product prices from Firestore (server-side truth)
 * - Recalculates total from server prices
 * - If the total doesn't match (>$0.50 difference), marks
 *   the invoice as 'Rechazada' (rejected)
 * - Validates coupon if one was applied
 * - Decrements stock for each item purchased
 */

const functions = require("firebase-functions");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");
const { initializeApp } = require("firebase-admin/app");

initializeApp();
const db = getFirestore();

exports.validateOrder = functions.firestore
  .document("invoices/{invoiceId}")
  .onCreate(async (snap, context) => {
  if (!snap) return;

  const invoice = snap.data();
  const invoiceRef = snap.ref;

  // ── IDEMPOTENCY: Skip if already validated (Firebase can retry on failure) ──
  if (invoice.serverValidated || invoice.status === 'Rechazada') {
    console.log(`SKIP: ${invoiceRef.id} already processed`);
    return;
  }

  // Skip POS orders (already validated by the admin system)
  if (invoice.sellerUid && invoice.sellerUid !== 'APP' && invoice.sellerUid !== 'WEB') {
    await invoiceRef.update({
      serverValidated: true,
      validatedAt: FieldValue.serverTimestamp(),
      validationNote: 'POS order — skipped server validation',
    });
    return;
  }

  try {
    const items = invoice.items || [];
    if (items.length === 0) {
      await invoiceRef.update({
        status: 'Rechazada',
        rejectionReason: 'Factura sin items.',
        validatedAt: FieldValue.serverTimestamp(),
      });
      return;
    }

    let serverTotal = 0;
    const stockUpdates = [];

    // ── 1. Verify each item's price from products collection ──
    for (const item of items) {
      if (!item.productId) {
        await invoiceRef.update({
          status: 'Rechazada',
          rejectionReason: `Item sin productId: ${item.productName || 'desconocido'}.`,
          validatedAt: FieldValue.serverTimestamp(),
        });
        return;
      }

      const productSnap = await db.collection('products').doc(item.productId).get();
      if (!productSnap.exists) {
        await invoiceRef.update({
          status: 'Rechazada',
          rejectionReason: `Producto ${item.productId} no existe.`,
          validatedAt: FieldValue.serverTimestamp(),
        });
        return;
      }

      const productData = productSnap.data();
      const variants = productData.variants || [];
      
      // Try to find variant by variantIndex first (most reliable), then by size/color
      let variant = null;
      let variantIndex = -1;

      if (item.variantIndex !== undefined && item.variantIndex >= 0 && item.variantIndex < variants.length) {
        variant = variants[item.variantIndex];
        variantIndex = item.variantIndex;
      }
      
      if (!variant) {
        // Fallback: find by size/color match
        const size = item.size || item.selectedSize || '';
        const color = item.color || item.selectedColor || '';
        if (size || color) {
          variantIndex = variants.findIndex(v =>
            (v.size || '') === size && (v.color || '') === color
          );
          if (variantIndex >= 0) variant = variants[variantIndex];
        }
      }

      if (!variant) {
        // Fallback: parse variantLabel "M / Negro"
        if (item.variantLabel) {
          const parts = item.variantLabel.split('/').map(s => s.trim());
          const labelSize = parts[0] !== 'N/A' ? parts[0] : '';
          const labelColor = parts[1] !== 'N/A' ? parts[1] : '';
          variantIndex = variants.findIndex(v =>
            (v.size || '') === labelSize && (v.color || '') === labelColor
          );
          if (variantIndex >= 0) variant = variants[variantIndex];
        }
      }

      if (!variant) {
        await invoiceRef.update({
          status: 'Rechazada',
          rejectionReason: `Variante no encontrada para ${item.productName || item.productId}. Index: ${item.variantIndex}, Label: ${item.variantLabel || 'N/A'}.`,
          validatedAt: FieldValue.serverTimestamp(),
        });
        return;
      }

      // Verify stock (only if we need to deduct — skip for already-deducted orders)
      const stock = parseInt(variant.stock) || 0;
      const qty = item.quantity || item.qty || 1;
      if (!invoice.stockDeducted && stock < qty) {
        await invoiceRef.update({
          status: 'Rechazada',
          rejectionReason: `Stock insuficiente para ${item.productName || productData.name}: ${stock} disponibles, ${qty} solicitados.`,
          validatedAt: FieldValue.serverTimestamp(),
        });
        return;
      }

      // Calculate server-side price
      const serverPrice = parseFloat(variant.price) || 0;
      let finalPrice = serverPrice;

      const offer = productData.offer;
      if (offer && offer.value > 0) {
        if (offer.type === 'percentage') {
          finalPrice = serverPrice - (serverPrice * offer.value / 100);
        } else {
          finalPrice = Math.max(0, serverPrice - offer.value);
        }
      }

      serverTotal += finalPrice * qty;

      stockUpdates.push({ productId: item.productId, variantIndex, qty });
    }

    // ── 2. Validate coupon if applied ──
    let couponDiscount = 0;
    if (invoice.appliedCoupon && invoice.appliedCoupon.couponId) {
      const couponSnap = await db.collection('coupons').doc(invoice.appliedCoupon.couponId).get();
      if (couponSnap.exists) {
        const coupon = couponSnap.data();
        if (coupon.active) {
          if (coupon.discountType === 'percentage') {
            couponDiscount = (serverTotal * coupon.discountValue) / 100;
          } else {
            couponDiscount = Math.min(coupon.discountValue, serverTotal);
          }
        }
      }
    }

    // ── 3. Calculate delivery cost ──
    const deliveryCost = parseFloat(invoice.deliveryCostUsd) || 0;
    const effectiveDelivery = invoice.appliedCoupon?.freeShipping ? 0 : deliveryCost;

    // ── 4. Compare totals ──
    const serverFinalTotal = Math.round((serverTotal - couponDiscount + effectiveDelivery) * 100) / 100;
    const clientTotal = parseFloat(invoice.total) || 0;
    const difference = Math.abs(serverFinalTotal - clientTotal);

    if (difference > 0.50) {
      await invoiceRef.update({
        status: 'Rechazada',
        rejectionReason: `Total no coincide. Servidor: $${serverFinalTotal.toFixed(2)}, Cliente: $${clientTotal.toFixed(2)}.`,
        serverCalculatedTotal: serverFinalTotal,
        validatedAt: FieldValue.serverTimestamp(),
      });
      console.warn(`ORDER REJECTED ${invoiceRef.id}: server=$${serverFinalTotal.toFixed(2)} vs client=$${clientTotal.toFixed(2)}`);
      return;
    }

    // ── 5. Order is valid — decrement stock (only if not already done) ──
    const batch = db.batch();

    if (!invoice.stockDeducted) {
      for (const update of stockUpdates) {
        const productRef = db.collection('products').doc(update.productId);
        const pSnap = await productRef.get();
        if (!pSnap.exists) continue;
        const variants = [...(pSnap.data().variants || [])];
        if (variants[update.variantIndex]) {
          const currentStock = parseInt(variants[update.variantIndex].stock) || 0;
          variants[update.variantIndex].stock = Math.max(0, currentStock - update.qty);
          batch.update(productRef, { variants });
        }
      }
    }

    // Mark as validated
    batch.update(invoiceRef, {
      serverValidated: true,
      serverCalculatedTotal: serverFinalTotal,
      validatedAt: FieldValue.serverTimestamp(),
    });

    await batch.commit();
    console.log(`ORDER VALIDATED ${invoiceRef.id}: $${serverFinalTotal.toFixed(2)} stockDeducted=${!!invoice.stockDeducted}`);

  } catch (error) {
    console.error(`ORDER VALIDATION ERROR ${invoiceRef.id}:`, error);
    try {
      await invoiceRef.update({
        validationError: error.message,
        validatedAt: FieldValue.serverTimestamp(),
      });
    } catch (updateErr) {
      console.error(`FAILED TO WRITE ERROR TO INVOICE ${invoiceRef.id}:`, updateErr);
    }
  }
});

// ══════════════════════════════════════════════════════════
// TASA BCV AUTOMÁTICA
// ══════════════════════════════════════════════════════════

/**
 * Fetch BCV rate from multiple sources with fallback.
 * Returns the rate as a number or null if all sources fail.
 */
async function getBcvRate() {
  // Source 1 (Primary): DolarAPI Venezuela — Tasa EURO BCV
  try {
    const res = await fetch('https://ve.dolarapi.com/v1/euros/oficial', {
      headers: { 'User-Agent': 'ALONZO-POS/1.0' },
      signal: AbortSignal.timeout(8000),
    });
    if (res.ok) {
      const data = await res.json();
      const rate = data?.promedio || data?.precio;
      if (rate && typeof rate === 'number' && rate > 0) {
        console.log(`EUR/BCV rate from DolarAPI: ${rate}`);
        return rate;
      }
    }
  } catch (e) {
    console.warn('DolarAPI failed:', e.message);
  }

  // Source 2 (Fallback): PyDolarVe — Tasa EURO BCV
  try {
    const res = await fetch('https://pydolarve.org/api/v1/dollar?page=bcv', {
      headers: { 'User-Agent': 'ALONZO-POS/1.0' },
      signal: AbortSignal.timeout(8000),
    });
    if (res.ok) {
      const data = await res.json();
      const rate = data?.monitors?.eur?.price;
      if (rate && typeof rate === 'number' && rate > 0) {
        console.log(`EUR/BCV rate from PyDolarVe: ${rate}`);
        return rate;
      }
    }
  } catch (e) {
    console.warn('PyDolarVe failed:', e.message);
  }

  // Source 3 (Fallback): alcambio.app
  try {
    const res = await fetch('https://api.alcambio.app/graphql', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'User-Agent': 'ALONZO-POS/1.0' },
      body: JSON.stringify({ query: '{ getRates { BCV { rateEur } } }' }),
      signal: AbortSignal.timeout(8000),
    });
    if (res.ok) {
      const data = await res.json();
      const rate = data?.data?.getRates?.BCV?.rateEur || data?.data?.getRates?.BCV?.rate;
      if (rate && typeof rate === 'number' && rate > 0) {
        console.log(`EUR/BCV rate from AlCambio: ${rate}`);
        return rate;
      }
    }
  } catch (e) {
    console.warn('AlCambio failed:', e.message);
  }

  return null;
}

/**
 * HTTP Callable — Manual refresh from POS/Web.
 * Requires authentication.
 */
exports.refreshBcvRate = functions.https.onCall(async (data, context) => {
  // Require authentication
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Debes iniciar sesión.');
  }

  const rate = await getBcvRate();
  if (!rate) {
    throw new functions.https.HttpsError('unavailable', 'No se pudo obtener la tasa BCV. Intenta más tarde.');
  }

  // Get previous rate — skip if identical
  const prev = await db.doc('config/exchangeRate').get();
  const prevRate = prev.exists ? prev.data().value : null;

  if (prevRate && Math.abs(prevRate - rate) < 0.01) {
    return { rate, previousRate: prevRate, updatedAt: new Date().toISOString(), changed: false };
  }

  // ATOMIC: Update rate + log history in one batch (prevents ghost updates without history)
  const now = new Date();
  const batch = db.batch();

  batch.set(db.doc('config/exchangeRate'), {
    value: rate,
    source: 'BCV-EUR',
    currency: 'EUR',
    updatedAt: FieldValue.serverTimestamp(),
    updatedBy: context.auth.uid,
    lastCheck: now.toISOString(),
  }, { merge: true });

  batch.set(db.collection('exchangeRateHistory').doc(), {
    previousRate: prevRate,
    newRate: rate,
    change: prevRate ? rate - prevRate : 0,
    source: 'BCV-EUR',
    method: 'manual',
    updatedBy: context.auth.uid,
    timestamp: FieldValue.serverTimestamp(),
  });

  await batch.commit();

  return { rate, previousRate: prevRate, updatedAt: now.toISOString(), changed: true };
});

/**
 * Scheduled — Runs daily at 9:00 AM and 5:00 PM Venezuela time.
 * Automatically updates the exchange rate in Firestore.
 */
exports.scheduledBcvRate = functions.pubsub
  .schedule('0 9,17 * * *')
  .timeZone('America/Caracas')
  .onRun(async () => {
    const rate = await getBcvRate();
    if (!rate) {
      console.error('SCHEDULED BCV: All sources failed');
      return;
    }

    const prev = await db.doc('config/exchangeRate').get();
    const prevRate = prev.exists ? prev.data().value : null;

    // Skip if rate hasn't changed (avoid unnecessary writes)
    if (prevRate && Math.abs(prevRate - rate) < 0.01) {
      console.log(`SCHEDULED BCV EUR: No change (${rate})`);
      return;
    }

    // ATOMIC: Update rate + log history in one batch
    const batch = db.batch();

    batch.set(db.doc('config/exchangeRate'), {
      value: rate,
      previousValue: prevRate,
      source: 'BCV-EUR',
      currency: 'EUR',
      updatedAt: FieldValue.serverTimestamp(),
      updatedBy: 'scheduled',
      lastCheck: new Date().toISOString(),
    }, { merge: true });

    batch.set(db.collection('exchangeRateHistory').doc(), {
      previousRate: prevRate,
      newRate: rate,
      change: prevRate ? rate - prevRate : 0,
      source: 'BCV-EUR',
      method: 'scheduled',
      updatedBy: 'scheduled',
      timestamp: FieldValue.serverTimestamp(),
    });

    await batch.commit();
    console.log(`SCHEDULED BCV EUR: Updated ${prevRate} → ${rate}`);
  });
