import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/providers.dart';

import '../../../cart/presentation/providers/cart_provider.dart';
import '../../data/datasources/checkout_firestore_datasource.dart';
import '../../data/repositories/checkout_repository_impl.dart';
import '../../domain/repositories/checkout_repository.dart';

// ═══════════════════════════════════════════════════════════
//  CHECKOUT STATE
// ═══════════════════════════════════════════════════════════

enum CheckoutStep { address, payment, summary, processing, confirmed, error }

/// Datos del cliente para la factura.
class ClientSnapshot {
  final String name;
  final String address;
  final String phone;
  final String rifCi;

  const ClientSnapshot({
    this.name = '',
    this.address = '',
    this.phone = '',
    this.rifCi = '',
  });

  bool get isValid => name.isNotEmpty && phone.isNotEmpty;

  Map<String, dynamic> toMap() => {
        'name': name,
        'address': address,
        'phone': phone,
        'rif_ci': rifCi,
      };

  ClientSnapshot copyWith({
    String? name,
    String? address,
    String? phone,
    String? rifCi,
  }) {
    return ClientSnapshot(
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      rifCi: rifCi ?? this.rifCi,
    );
  }
}

/// Tipo de entrega.
enum DeliveryType {
  pickup('pick-up', 'Retiro en tienda'),
  delivery('delivery', 'Envío a domicilio');

  final String value;
  final String label;
  const DeliveryType(this.value, this.label);
}

class CheckoutState {
  final CheckoutStep step;
  final ClientSnapshot client;
  final DeliveryType deliveryType;
  final double deliveryCostUsd;
  final double exchangeRate;
  final String paymentMethod;
  final String observation;
  final String? orderId;
  final int? numericId;
  final String? errorMessage;
  // ── Coupon ──
  final String? couponCode;
  final String? couponId;
  final double couponDiscount;
  final String couponDescription;
  final bool couponFreeShipping;
  final String? couponError;

  const CheckoutState({
    this.step = CheckoutStep.address,
    this.client = const ClientSnapshot(),
    this.deliveryType = DeliveryType.pickup,
    this.deliveryCostUsd = 0,
    this.exchangeRate = 0,
    this.paymentMethod = 'Efectivo (\$)',
    this.observation = '',
    this.orderId,
    this.numericId,
    this.errorMessage,
    this.couponCode,
    this.couponId,
    this.couponDiscount = 0,
    this.couponDescription = '',
    this.couponFreeShipping = false,
    this.couponError,
  });

  bool get hasCoupon => couponCode != null && couponDiscount > 0;

  CheckoutState copyWith({
    CheckoutStep? step,
    ClientSnapshot? client,
    DeliveryType? deliveryType,
    double? deliveryCostUsd,
    double? exchangeRate,
    String? paymentMethod,
    String? observation,
    String? orderId,
    int? numericId,
    String? errorMessage,
    String? couponCode,
    String? couponId,
    double? couponDiscount,
    String? couponDescription,
    bool? couponFreeShipping,
    String? couponError,
  }) {
    return CheckoutState(
      step: step ?? this.step,
      client: client ?? this.client,
      deliveryType: deliveryType ?? this.deliveryType,
      deliveryCostUsd: deliveryCostUsd ?? this.deliveryCostUsd,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      observation: observation ?? this.observation,
      orderId: orderId ?? this.orderId,
      numericId: numericId ?? this.numericId,
      errorMessage: errorMessage,
      couponCode: couponCode ?? this.couponCode,
      couponId: couponId ?? this.couponId,
      couponDiscount: couponDiscount ?? this.couponDiscount,
      couponDescription: couponDescription ?? this.couponDescription,
      couponFreeShipping: couponFreeShipping ?? this.couponFreeShipping,
      couponError: couponError,
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  CHECKOUT NOTIFIER
// ═══════════════════════════════════════════════════════════

/// Notifier del checkout.
///
/// Solo conoce [CheckoutRepository] — sin imports de Firestore o FirebaseAuth.
class CheckoutNotifier extends StateNotifier<CheckoutState> {
  final CheckoutRepository _repo;
  final CartNotifier _cartNotifier;

  CheckoutNotifier(this._repo, this._cartNotifier)
      : super(const CheckoutState()) {
    _loadExchangeRate();
  }

  Future<void> _loadExchangeRate() async {
    try {
      final rate = await _repo.getExchangeRate();
      if (!mounted) return;
      if (rate > 0) state = state.copyWith(exchangeRate: rate);
    } catch (_) {
      // Si falla, dejar en 0
    }
  }

  void updateClient(ClientSnapshot client) =>
      state = state.copyWith(client: client);

  void updateDeliveryType(DeliveryType type) {
    state = state.copyWith(
      deliveryType: type,
      deliveryCostUsd: type == DeliveryType.pickup ? 0 : state.deliveryCostUsd,
    );
  }

  void updateDeliveryCost(double cost) =>
      state = state.copyWith(deliveryCostUsd: cost);

  void updateExchangeRate(double rate) =>
      state = state.copyWith(exchangeRate: rate);

  void updatePaymentMethod(String method) =>
      state = state.copyWith(paymentMethod: method);

  void updateObservation(String obs) =>
      state = state.copyWith(observation: obs);

  /// Validate and apply a coupon code.
  Future<void> applyCoupon(String code, double subtotal) async {
    final trimmed = code.toUpperCase().trim();
    if (trimmed.isEmpty) return;

    try {
      final snap = await FirebaseFirestore.instance
          .collection('coupons')
          .where('code', isEqualTo: trimmed)
          .limit(1)
          .get();

      if (snap.docs.isEmpty) {
        state = state.copyWith(couponError: 'Cupón no encontrado.');
        return;
      }

      final doc = snap.docs.first;
      final data = doc.data();

      if (data['active'] != true) {
        state = state.copyWith(couponError: 'Este cupón está desactivado.');
        return;
      }

      final now = DateTime.now().millisecondsSinceEpoch;
      final startsAt = data['startsAt'] as Timestamp?;
      final expiresAt = data['expiresAt'] as Timestamp?;
      if (startsAt != null && startsAt.millisecondsSinceEpoch > now) {
        state = state.copyWith(couponError: 'Este cupón aún no está vigente.');
        return;
      }
      if (expiresAt != null && expiresAt.millisecondsSinceEpoch < now) {
        state = state.copyWith(couponError: 'Este cupón ha expirado.');
        return;
      }

      final maxTotal = (data['maxUsesTotal'] as num?)?.toInt() ?? 0;
      final usedCount = (data['usedCount'] as num?)?.toInt() ?? 0;
      if (maxTotal > 0 && usedCount >= maxTotal) {
        state = state.copyWith(couponError: 'Este cupón alcanzó su límite de usos.');
        return;
      }

      final minPurchase = (data['minPurchase'] as num?)?.toDouble() ?? 0;
      if (minPurchase > 0 && subtotal < minPurchase) {
        state = state.copyWith(couponError: 'Compra mínima de \$${minPurchase.toStringAsFixed(2)} requerida.');
        return;
      }

      // Calculate discount
      final discountType = data['discountType'] as String? ?? 'percentage';
      final discountValue = (data['discountValue'] as num?)?.toDouble() ?? 0;
      double discount = 0;
      if (discountType == 'percentage') {
        discount = (subtotal * discountValue) / 100;
      } else {
        discount = discountValue.clamp(0, subtotal);
      }

      final desc = discountType == 'percentage'
          ? '${discountValue.toStringAsFixed(0)}% de descuento'
          : '\$${discountValue.toStringAsFixed(2)} de descuento';

      state = state.copyWith(
        couponCode: data['code'] as String,
        couponId: doc.id,
        couponDiscount: (discount * 100).round() / 100,
        couponDescription: desc,
        couponFreeShipping: data['freeShipping'] == true,
        couponError: null,
      );
    } catch (e) {
      state = state.copyWith(couponError: 'Error al validar cupón.');
    }
  }

  void removeCoupon() {
    state = state.copyWith(
      couponCode: null,
      couponId: null,
      couponDiscount: 0,
      couponDescription: '',
      couponFreeShipping: false,
      couponError: null,
    );
  }

  void goToPayment() {
    if (state.client.isValid) {
      state = state.copyWith(step: CheckoutStep.payment);
    }
  }

  void goToSummary() => state = state.copyWith(step: CheckoutStep.summary);

  void goBack() {
    if (state.step == CheckoutStep.summary) {
      state = state.copyWith(step: CheckoutStep.payment);
    } else if (state.step == CheckoutStep.payment) {
      state = state.copyWith(step: CheckoutStep.address);
    }
  }

  /// Confirma la orden y la guarda en Firestore a través del repositorio.
  Future<void> placeOrder() async {
    state = state.copyWith(step: CheckoutStep.processing);

    try {
      final cartState = _cartNotifier.state;
      final offerDiscount = cartState.totalSaved;
      final effectiveDeliveryCost = state.couponFreeShipping ? 0.0 : state.deliveryCostUsd;
      final total = cartState.total - state.couponDiscount + effectiveDeliveryCost;

      final items = cartState.items.map((item) => {
            'productId': item.productId,
            'productName': item.productName,
            'priceAtSale': item.price,
            'quantity': item.quantity,
            'variantIndex': 0,
            'variantLabel': '${item.selectedSize} / ${item.selectedColor}',
            'discount': item.hasOffer
                ? {'type': item.offerType, 'value': item.offerValue}
                : {'type': 'none', 'value': 0},
            // Legacy compat
            'titulo': item.productName,
            'name': item.productName,
            'price': item.price,
            'qty': item.quantity,
            'rowTotal': item.subtotal,
            'size': item.selectedSize,
            'color': item.selectedColor,
            'img': item.imageUrl,
          }).toList();

      final totalDiscount = offerDiscount + state.couponDiscount;

      final invoiceData = {
        'abonos': [],
        'changeGiven': 0,
        'clientSnapshot': state.client.toMap(),
        'date': FieldValue.serverTimestamp(),
        'deliveryCostUsd': effectiveDeliveryCost,
        'deliveryPaidInStore': state.deliveryType == DeliveryType.pickup,
        'deliveryType': state.deliveryType.value,
        'exchangeRate': state.exchangeRate,
        'items': items,
        'observation': state.observation,
        'payments': [
          {
            'amountUsd': total,
            'amountVes': total * state.exchangeRate,
            'method': state.paymentMethod,
          }
        ],
        'sellerName': 'App ALONZO',
        'sellerUid': 'APP',
        'status': 'Creada',
        'total': total,
        'totalDiscount': totalDiscount > 0
            ? {'type': state.hasCoupon ? 'coupon' : 'offer', 'value': totalDiscount}
            : {'type': 'none', 'value': 0},
        'offerDiscount': offerDiscount,
        if (state.hasCoupon)
          'appliedCoupon': {
            'couponId': state.couponId,
            'code': state.couponCode,
            'discountAmount': state.couponDiscount,
            'description': state.couponDescription,
            'freeShipping': state.couponFreeShipping,
          },
        'appliedPromotions': [],
      };

      final result = await _repo.placeOrder(invoiceData);
      if (!mounted) return;

      // Record coupon usage
      if (state.hasCoupon && state.couponId != null) {
        try {
          await FirebaseFirestore.instance.collection('coupons').doc(state.couponId).update({
            'usedCount': FieldValue.increment(1),
          });
        } catch (_) {}
      }

      _cartNotifier.clearCart();
      state = state.copyWith(
        step: CheckoutStep.confirmed,
        orderId: result.orderId,
        numericId: result.numericId,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        step: CheckoutStep.error,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() => state = const CheckoutState();
}

// ═══════════════════════════════════════════════════════════
//  PROVIDERS
// ═══════════════════════════════════════════════════════════

/// Provider del repositorio de checkout.
final checkoutRepositoryProvider = Provider<CheckoutRepositoryImpl>((ref) {
  return CheckoutRepositoryImpl(
    dataSource: CheckoutFirestoreDataSource(
      firestore: ref.read(firestoreProvider),
      auth: ref.read(firebaseAuthProvider),
    ),
  );
});

/// Provider global del checkout.
final checkoutProvider =
    StateNotifierProvider<CheckoutNotifier, CheckoutState>((ref) {
  return CheckoutNotifier(
    ref.read(checkoutRepositoryProvider),
    ref.read(cartProvider.notifier),
  );
});
