import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../auth/domain/entities/user_profile_entity.dart';

/// Data source que interactúa con Firestore para el perfil de usuario.
///
/// Colección: clients/{uid}
class UserProfileFirestoreDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  UserProfileFirestoreDataSource({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth;

  /// Carga el perfil del usuario. Si no existe, pre-llena con datos de Auth.
  Future<UserProfile> getProfile() async {
    final user = _auth.currentUser;
    if (user == null) return const UserProfile();

    final doc =
        await _firestore.collection('clients').doc(user.uid).get();

    if (doc.exists && doc.data() != null) {
      return UserProfile.fromMap(doc.data()!);
    }

    // Sin perfil guardado → pre-llenar con datos de FirebaseAuth
    return UserProfile(
      name: user.displayName ?? '',
      email: user.email ?? '',
    );
  }

  /// Guarda (merge) el perfil en Firestore.
  Future<void> saveProfile(UserProfile profile) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('clients')
        .doc(user.uid)
        .set(profile.toMap(), SetOptions(merge: true));
  }

  /// Busca un cliente existente por su cédula/RIF.
  /// Retorna null si no encuentra ninguno.
  Future<Map<String, dynamic>?> searchByRifCi(String rifCi) async {
    final query = await _firestore
        .collection('clients')
        .where('rif_ci', isEqualTo: rifCi)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;
    return {'id': query.docs.first.id, ...query.docs.first.data()};
  }

  /// Verifica si el usuario actual tiene perfil completo (con nombre).
  Future<bool> checkProfileExists() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final doc =
          await _firestore.collection('clients').doc(user.uid).get();
      return doc.exists &&
          (doc.data()?['name'] as String? ?? '').isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
