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
  });

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
      final total = cartState.total + state.deliveryCostUsd;

      final items = cartState.items.map((item) => {
            'productId': item.productId,
            'quantity': item.quantity,
            'variantIndex': 0,
            'discount': {'type': 'none', 'value': 0},
          }).toList();

      final invoiceData = {
        'abonos': [],
        'changeGiven': 0,
        'clientSnapshot': state.client.toMap(),
        'date': FieldValue.serverTimestamp(),
        'deliveryCostUsd': state.deliveryCostUsd,
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
        'status': 'Creada',
        'total': total,
        'totalDiscount': {'type': 'none', 'value': 0},
      };

      final result = await _repo.placeOrder(invoiceData);
      if (!mounted) return;

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
