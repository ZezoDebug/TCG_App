// lib/models/user.dart  (arquivo NOVO)

class User {
  final int? id;
  final String username;
  final String email;
  final String passwordHash;

  User({
    this.id,
    required this.username,
    required this.email,
    required this.passwordHash,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password_hash': passwordHash,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      username: map['username'] as String,
      email: map['email'] as String,
      passwordHash: map['password_hash'] as String,
    );
  }
}