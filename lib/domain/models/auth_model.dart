import '../interfaces/entity.dart';

class Auth implements Entity {
  @override
  final String id;
  final String email;
  final String? token;
  final DateTime? expiresAt;

  Auth({required this.id, required this.email, this.token, this.expiresAt});

  factory Auth.fromMap(Map<String, dynamic> map) {
    return Auth(
      id: map['id'],
      email: map['email'],
      token: map['token'],
      expiresAt:
          map['expires_at'] != null ? DateTime.parse(map['expires_at']) : null,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'token': token,
      'expires_at': expiresAt?.toIso8601String(),
    };
  }

  Auth copyWith({String? email, String? token, DateTime? expiresAt}) {
    return Auth(
      id: this.id,
      email: email ?? this.email,
      token: token ?? this.token,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  bool get isTokenValid {
    if (token == null || expiresAt == null) return false;
    return DateTime.now().isBefore(expiresAt!);
  }
}
