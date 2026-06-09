import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:web/web.dart' as web;

import '../models/user.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static const String _storageKey = 'tcg_users';

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  String _hash(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  List<User> _readUsers() {
    final raw = web.window.localStorage.getItem(_storageKey);
    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => User.fromMap(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  void _writeUsers(List<User> users) {
    final data = users.map((user) => user.toMap()).toList();
    web.window.localStorage.setItem(_storageKey, jsonEncode(data));
  }

  Future<bool> register(String username, String email, String password) async {
    final users = _readUsers();
    final normalizedUsername = username.trim();
    final normalizedEmail = email.trim();

    final alreadyExists = users.any(
      (user) =>
          user.username.toLowerCase() == normalizedUsername.toLowerCase() ||
          user.email.toLowerCase() == normalizedEmail.toLowerCase(),
    );

    if (alreadyExists) return false;

    final nextId = users.isEmpty
        ? 1
        : users.map((user) => user.id ?? 0).reduce((a, b) => a > b ? a : b) +
            1;

    users.add(
      User(
        id: nextId,
        username: normalizedUsername,
        email: normalizedEmail,
        passwordHash: _hash(password),
      ),
    );
    _writeUsers(users);
    return true;
  }

  Future<User?> login(String username, String password) async {
    final passwordHash = _hash(password);
    final normalizedUsername = username.trim();

    for (final user in _readUsers()) {
      if (user.username == normalizedUsername &&
          user.passwordHash == passwordHash) {
        return user;
      }
    }

    return null;
  }
}
