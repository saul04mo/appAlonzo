import '../../domain/repositories/checkout_repository.dart';
import '../datasources/checkout_firestore_datasource.dart';

/// Implementación concreta del repositorio de checkout.
///
/// Delega todas las operaciones al [CheckoutFirestoreDataSource].
class CheckoutRepositoryImpl implements CheckoutRepository {
  final CheckoutFirestoreDataSource _dataSource;

  CheckoutRepositoryImpl({required CheckoutFirestoreDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Future<double> getExchangeRate() => _dataSource.getExchangeRate();

  @override
  Future<({String orderId, int numericId})> placeOrder(
          Map<String, dynamic> invoiceData) =>
      _dataSource.placeOrder(invoiceData);
}
