import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  // currentUser é nullable, então o tratamento é necessário.
  final User? currentUser = FirebaseAuth.instance.currentUser;

  void _resetPassword() async {
    // Garante que o email não é nulo antes de prosseguir.
    if (currentUser?.email == null) return;

    final res = await _authService.resetPassword(email: currentUser!.email!);

    if (!mounted) return;

    final String message = res == 'success'
        ? 'E-mail de redefinição enviado! Verifique sua caixa de entrada.'
        : res ?? 'Ocorreu um erro.';

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _logout() async {
    await _authService.signOut();

    if (!mounted) return;

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
                // SOLUÇÃO: Lógica ajustada para remover o aviso.
                currentUser?.email ?? 'E-mail não disponível',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 32),
            CustomOutlinedButton(
              text: 'Redefinir Senha',
              // A função _resetPassword já faz a verificação de nulo.
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