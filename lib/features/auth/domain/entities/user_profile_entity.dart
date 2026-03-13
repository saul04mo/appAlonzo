/// Entidad de dominio que representa el perfil del usuario.
///
/// Sin dependencias de Firebase — clase Dart pura.
class UserProfile {
  final String name;
  final String email;
  final String phone;
  final String rifCi;
  final String address;

  const UserProfile({
    this.name = '',
    this.email = '',
    this.phone = '',
    this.rifCi = '',
    this.address = '',
  });

  bool get isComplete => name.isNotEmpty && phone.isNotEmpty;

  factory UserProfile.fromMap(Map<String, dynamic> data) {
    return UserProfile(
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      rifCi: data['rif_ci'] as String? ?? '',
      address: data['address'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'phone': phone,
        'rif_ci': rifCi,
        'address': address,
      };

  UserProfile copyWith({
    String? name,
    String? email,
    String? phone,
    String? rifCi,
    String? address,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      rifCi: rifCi ?? this.rifCi,
      address: address ?? this.address,
    );
  }
}
