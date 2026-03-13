import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/providers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Modelo de un pedido (invoice).
class OrderItem {
  final String id;
  final int numericId;
  final String status;
  final DateTime? date;
  final double total;
  final double exchangeRate;
  final String deliveryType;
  final String observation;
  final String paymentMethod;
  final int itemCount;

  const OrderItem({
    required this.id,
    required this.numericId,
    required this.status,
    this.date,
    required this.total,
    required this.exchangeRate,
    required this.deliveryType,
    this.observation = '',
    this.paymentMethod = '',
    this.itemCount = 0,
  });

  factory OrderItem.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final payments = data['payments'] as List<dynamic>? ?? [];
    final items = data['items'] as List<dynamic>? ?? [];
    final firstPayment =
        payments.isNotEmpty ? payments[0] as Map<String, dynamic> : {};

    Timestamp? ts = data['date'] as Timestamp?;

    return OrderItem(
      id: doc.id,
      numericId: data['numericId'] as int? ?? 0,
      status: data['status'] as String? ?? 'Desconocido',
      date: ts?.toDate(),
      total: (data['total'] as num?)?.toDouble() ?? 0,
      exchangeRate: (data['exchangeRate'] as num?)?.toDouble() ?? 0,
      deliveryType: data['deliveryType'] as String? ?? '',
      observation: data['observation'] as String? ?? '',
      paymentMethod: firstPayment['method'] as String? ?? '',
      itemCount: items.length,
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  REPOSITORY: contrato abstracto
// ═══════════════════════════════════════════════════════════

/// Contrato del repositorio de pedidos.
abstract class OrdersRepository {
  /// Stream reactivo de pedidos del usuario actual, ordenados por fecha desc.
  Stream<List<OrderItem>> watchOrders(String uid);
}

// ═══════════════════════════════════════════════════════════
//  DATASOURCE
// ═══════════════════════════════════════════════════════════

/// Data source que interactúa con Firestore para los pedidos.
class OrdersFirestoreDataSource {
  final FirebaseFirestore _firestore;

  OrdersFirestoreDataSource({required FirebaseFirestore firestore})
      : _firestore = firestore;

  Stream<List<OrderItem>> watchOrders(String uid) {
    return _firestore
        .collection('invoices')
        .where('clientId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
      final orders =
          snapshot.docs.map((doc) => OrderItem.fromDoc(doc)).toList();
      orders.sort((a, b) {
        if (a.date == null && b.date == null) return 0;
        if (a.date == null) return 1;
        if (b.date == null) return -1;
        return b.date!.compareTo(a.date!);
      });
      return orders;
    });
  }
}

// ═══════════════════════════════════════════════════════════
//  REPOSITORY IMPL
// ═══════════════════════════════════════════════════════════

class OrdersRepositoryImpl implements OrdersRepository {
  final OrdersFirestoreDataSource _dataSource;

  OrdersRepositoryImpl({required OrdersFirestoreDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Stream<List<OrderItem>> watchOrders(String uid) =>
      _dataSource.watchOrders(uid);
}

// ═══════════════════════════════════════════════════════════
//  PROVIDERS
// ═══════════════════════════════════════════════════════════

/// Provider del repositorio de pedidos.
final ordersRepositoryProvider = Provider<OrdersRepositoryImpl>((ref) {
  return OrdersRepositoryImpl(
    dataSource: OrdersFirestoreDataSource(
      firestore: ref.read(firestoreProvider),
    ),
  );
});

/// Provider que escucha los pedidos del usuario actual en tiempo real.
final ordersProvider = StreamProvider<List<OrderItem>>((ref) {
  final auth = ref.watch(authNotifierProvider);
  final uid = auth.user?.uid;

  if (uid == null) return Stream.value([]);

  return ref.read(ordersRepositoryProvider).watchOrders(uid);
});
