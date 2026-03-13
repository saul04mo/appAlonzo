/// Contrato del repositorio de checkout.
///
/// La capa de dominio solo conoce esta interfaz abstracta.
/// La implementación concreta vive en `data/repositories/`.
abstract class CheckoutRepository {
  /// Obtiene la tasa de cambio USD→VES desde Firestore (config/exchangeRate).
  Future<double> getExchangeRate();

  /// Guarda una factura en Firestore y retorna el docId y numericId
  /// generados. Usa transacción para garantizar unicidad del numericId.
  Future<({String orderId, int numericId})> placeOrder(
      Map<String, dynamic> invoiceData);
}
