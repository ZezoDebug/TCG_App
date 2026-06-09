import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/database_helper.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;

  bool get isLoggedIn => _currentUser != null;
  User? get currentUser => _currentUser;

  final _db = DatabaseHelper();


  Future<String?> login(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      return 'Preencha todos os campos';
    }
    final user = await _db.login(username.trim(), password);
    if (user != null) {
      _currentUser = user;
      notifyListeners();
      return null;
    }
    return 'Usuário ou senha incorretos';
  }

  Future<String?> register(
    String username,
    String email,
    String password,
    String confirm,
  ) async {
    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      return 'Preencha todos os campos';
    }
    if (password != confirm) return 'As senhas não coincidem';
    if (password.length < 6) return 'Senha mínima de 6 caracteres';

    final ok = await _db.register(username.trim(), email.trim(), password);
    return ok ? null : 'Usuário ou e-mail já cadastrado';
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}