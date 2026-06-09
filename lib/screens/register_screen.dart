import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const _surfaceColor = Colors.white;
  static const _accentColor = Colors.red;
  static const _warmAccentColor = Colors.redAccent;

  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;
  bool _hide1 = true;
  bool _hide2 = true;

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    setState(() => _loading = true);
    final err = await context.read<AuthProvider>().register(
      _username.text,
      _email.text,
      _password.text,
      _confirm.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), backgroundColor: Colors.red.shade700),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Conta criada! Faca login.'),
          backgroundColor: Colors.green.shade700,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: const Text('Cadastro')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildRegisterCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: _accentColor.withValues(alpha: 0.16),
            shape: BoxShape.circle,
            border: Border.all(color: _accentColor.withValues(alpha: 0.28)),
          ),
          child: const Icon(
            Icons.person_add_alt_1,
            size: 36,
            color: _accentColor,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Crie sua conta',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 30,
            height: 1,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _warmAccentColor.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Novo jogador',
                  style: TextStyle(
                    color: _warmAccentColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Spacer(),
              Icon(Icons.shield, color: Colors.black54),
            ],
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _username,
            label: 'Usuario',
            icon: Icons.person,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 14),
          _buildTextField(
            controller: _email,
            label: 'E-mail',
            icon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 14),
          _buildTextField(
            controller: _password,
            label: 'Senha',
            icon: Icons.lock,
            obscureText: _hide1,
            textInputAction: TextInputAction.next,
            suffixIcon: IconButton(
              icon: Icon(_hide1 ? Icons.visibility : Icons.visibility_off),
              onPressed: () => setState(() => _hide1 = !_hide1),
            ),
          ),
          const SizedBox(height: 14),
          _buildTextField(
            controller: _confirm,
            label: 'Confirmar senha',
            icon: Icons.lock_outline,
            obscureText: _hide2,
            textInputAction: TextInputAction.done,
            suffixIcon: IconButton(
              icon: Icon(_hide2 ? Icons.visibility : Icons.visibility_off),
              onPressed: () => setState(() => _hide2 = !_hide2),
            ),
            onSubmitted: (_) => _register(),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _loading ? null : _register,
            style: FilledButton.styleFrom(
              backgroundColor: _accentColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _loading
                ? const SizedBox(
                    width: 21,
                    height: 21,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Cadastrar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    bool obscureText = false,
    Widget? suffixIcon,
    ValueChanged<String>? onSubmitted,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.black12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.black12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _accentColor, width: 1.6),
        ),
      ),
    );
  }
}
