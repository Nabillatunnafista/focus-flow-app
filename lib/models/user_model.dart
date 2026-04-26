// lib/models/user_model.dart

class UserModel {
  final String id;
  final String email;
  final String? name;
  final String? avatarUrl;

  const UserModel({
    required this.id,
    required this.email,
    this.name,
    this.avatarUrl,
  });

  // Fungsi untuk mengubah JSON dari Backend Go menjadi Object Flutter
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  // Fungsi untuk mengubah Object Flutter menjadi JSON (jika perlu dikirim ke server)
  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'avatar_url': avatarUrl,
      };
}

/// Request untuk Login
class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };
}

/// Request untuk Register
class RegisterRequest {
  final String email;
  final String password;
  final String? name;

  const RegisterRequest({
    required this.email,
    required this.password,
    this.name,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        if (name != null) 'name': name,
      };
}

class AuthResponse {
  final String accessToken;
  final String? refreshToken;
  final UserModel user;

  const AuthResponse({
    required this.accessToken,
    this.refreshToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access_token'] as String? ?? json['token'] as String? ?? '',
      refreshToken: json['refresh_token'] as String?,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}