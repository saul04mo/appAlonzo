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

  // Skip POS orders (already validated by the admin system)
  if (invoice.sellerUid && invoice.sellerUid !== 'APP' && invoice.sellerUid !== 'WEB') {
    return;
  }

  try {
    const items = invoice.items || [];
    let serverTotal = 0;
    const stockUpdates = [];

    // ── 1. Verify each item's price from products collection ──
    for (const item of items) {
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
      const variant = variants.find(v =>
        v.size === (item.size || item.selectedSize) &&
        v.color === (item.color || item.selectedColor)
      );

      if (!variant) {
        await invoiceRef.update({
          status: 'Rechazada',
          rejectionReason: `Variante no encontrada para ${item.productName}.`,
          validatedAt: FieldValue.serverTimestamp(),
        });
        return;
      }

      // Verify stock
      const stock = parseInt(variant.stock) || 0;
      const qty = item.quantity || item.qty || 1;
      if (stock < qty) {
        await invoiceRef.update({
          status: 'Rechazada',
          rejectionReason: `Stock insuficiente para ${item.productName}: ${stock} disponibles, ${qty} solicitados.`,
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

      // Queue stock decrement
      const variantIndex = variants.indexOf(variant);
      stockUpdates.push({
        productId: item.productId,
        variantIndex,
        qty,
      });
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
    if (invoice.appliedCoupon?.freeShipping) {
      // Free shipping via coupon — set to 0
    }
    const effectiveDelivery = invoice.appliedCoupon?.freeShipping ? 0 : deliveryCost;

    // ── 4. Compare totals ──
    const serverFinalTotal = serverTotal - couponDiscount + effectiveDelivery;
    const clientTotal = parseFloat(invoice.total) || 0;
    const difference = Math.abs(serverFinalTotal - clientTotal);

    if (difference > 0.50) {
      // Price manipulation detected!
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
      // Stock not yet deducted (e.g., Flutter app orders) — decrement now
      for (const update of stockUpdates) {
        const productRef = db.collection('products').doc(update.productId);
        const pSnap = await productRef.get();
        const variants = [...(pSnap.data().variants || [])];
        if (variants[update.variantIndex]) {
          const currentStock = parseInt(variants[update.variantIndex].stock) || 0;
          variants[update.variantIndex].stock = Math.max(0, currentStock - update.qty);
          batch.update(productRef, { variants });
        }
      }
    }
    // else: stock was already deducted by Web/POS server-side transaction

    // Mark as validated
    batch.update(invoiceRef, {
      serverValidated: true,
      serverCalculatedTotal: serverFinalTotal,
      validatedAt: FieldValue.serverTimestamp(),
    });

    await batch.commit();
    console.log(`ORDER VALIDATED ${invoiceRef.id}: $${serverFinalTotal.toFixed(2)}`);

  } catch (error) {
    console.error(`ORDER VALIDATION ERROR ${invoiceRef.id}:`, error);
    await invoiceRef.update({
      validationError: error.message,
      validatedAt: FieldValue.serverTimestamp(),
    });
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
 * Call from client: firebase.functions().httpsCallable('refreshBcvRate')()
 */
exports.refreshBcvRate = functions.https.onCall(async (data, context) => {
  const rate = await getBcvRate();
  if (!rate) {
    throw new functions.https.HttpsError('unavailable', 'No se pudo obtener la tasa BCV. Intenta más tarde.');
  }

  // Get previous rate
  const prev = await db.doc('config/exchangeRate').get();
  const prevRate = prev.exists ? prev.data().value : null;

  const now = new Date();
  await db.doc('config/exchangeRate').set({
    value: rate,
    source: 'BCV-EUR',
    currency: 'EUR',
    updatedAt: FieldValue.serverTimestamp(),
    updatedBy: context.auth?.uid || 'system',
    lastCheck: now.toISOString(),
  }, { merge: true });

  // Log to history
  await db.collection('exchangeRateHistory').add({
    previousRate: prevRate,
    newRate: rate,
    change: prevRate ? rate - prevRate : 0,
    source: 'BCV-EUR',
    method: 'manual',
    updatedBy: context.auth?.uid || 'system',
    timestamp: FieldValue.serverTimestamp(),
  });

  return { rate, previousRate: prevRate, updatedAt: now.toISOString() };
});

/**
 * Scheduled — Runs daily at 1:00 PM UTC (9:00 AM Venezuela).
 * Automatically updates the exchange rate in Firestore.
 */
exports.scheduledBcvRate = functions.pubsub
  .schedule('0 13 * * *')
  .timeZone('America/Caracas')
  .onRun(async () => {
    const rate = await getBcvRate();
    if (!rate) {
      console.error('SCHEDULED BCV: All sources failed');
      return;
    }

    const prev = await db.doc('config/exchangeRate').get();
    const prevRate = prev.exists ? prev.data().value : null;

    await db.doc('config/exchangeRate').set({
      value: rate,
      previousValue: prevRate,
      source: 'BCV-EUR',
      currency: 'EUR',
      updatedAt: FieldValue.serverTimestamp(),
      updatedBy: 'scheduled',
      lastCheck: new Date().toISOString(),
    }, { merge: true });

    // Log to history
    await db.collection('exchangeRateHistory').add({
      previousRate: prevRate,
      newRate: rate,
      change: prevRate ? rate - prevRate : 0,
      source: 'BCV-EUR',
      method: 'scheduled',
      updatedBy: 'scheduled',
      timestamp: FieldValue.serverTimestamp(),
    });

    console.log(`SCHEDULED BCV EUR: Updated ${prevRate} → ${rate}`);
  });
