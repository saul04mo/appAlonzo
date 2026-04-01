import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Data source que interactúa con Firestore para el checkout.
///
/// Colecciones: config/exchangeRate, invoices
class CheckoutFirestoreDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CheckoutFirestoreDataSource({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth;

  /// Obtiene la tasa de cambio USD→VES desde config/exchangeRate.
  Future<double> getExchangeRate() async {
    final doc =
        await _firestore.collection('config').doc('exchangeRate').get();

    if (doc.exists && doc.data() != null) {
      return (doc.data()!['value'] as num?)?.toDouble() ?? 0;
    }
    return 0;
  }

  /// Guarda la factura en Firestore usando transacción atómica.
  /// Retorna (orderId, numericId).
  Future<({String orderId, int numericId})> placeOrder(
      Map<String, dynamic> invoiceData) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    // Add clientId to the invoice
    invoiceData['clientId'] = user.uid;
    invoiceData['clientEmail'] = user.email ?? '';

    final invoiceRef = _firestore.collection('invoices').doc();
    final counterRef = _firestore.collection('config').doc('orderCounter');

    final numericId = await _firestore.runTransaction<int>((tx) async {
      // Read counter inside the transaction (atomic)
      final counterSnap = await tx.get(counterRef);
      final lastId = counterSnap.exists
          ? (counterSnap.data()?['value'] as int? ?? 0)
          : 0;
      final nextId = lastId + 1;

      // Write both atomically
      tx.set(counterRef, {'value': nextId});
      tx.set(invoiceRef, {...invoiceData, 'numericId': nextId});
      return nextId;
    });

    return (orderId: invoiceRef.id, numericId: numericId);
  }
}
