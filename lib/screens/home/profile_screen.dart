import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';
// import 'package:logger/logger.dart'; // Use se quiser logar erros

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final User? currentUser = FirebaseAuth.instance.currentUser;
  // final Logger _logger = Logger(); // Use se quiser logar erros

  void _resetPassword() async {
    if (currentUser?.email == null) return;

    String? res = await _authService.resetPassword(email: currentUser!.email!);

    if (!mounted) return; // Protege contra uso incorreto do context

    final String message = res == 'success'
        ? 'E-mail de redefinição enviado! Verifique sua caixa de entrada.'
        : res ?? 'Ocorreu um erro.';

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

    // _logger.i('Resultado da redefinição de senha: $message'); // Opcional
  }

  void _logout() async {
    await _authService.signOut();

    if (!mounted) return; // Protege contra uso incorreto do context

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                currentUser?.email ?? 'E-mail não encontrado',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 32),
            CustomOutlinedButton(
              text: 'Redefinir Senha',
              onPressed: _resetPassword,
            ),
            const Spacer(),
            CustomElevatedButton(
              text: 'Sair (Logout)',
              onPressed: _logout,
            ),
          ],
        ),
      ),
    );
  }
}
