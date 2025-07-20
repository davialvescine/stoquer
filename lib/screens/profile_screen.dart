// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stoquer/models/usuario_model.dart';
import 'package:stoquer/services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final usuario = Provider.of<UsuarioModel?>(context);

    if (usuario == null) {
      return const Scaffold(body: Center(child: Text('Usuário não encontrado.')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Meu Perfil')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(usuario.nome),
            subtitle: const Text('Nome'),
          ),
          ListTile(
            leading: const Icon(Icons.email),
            title: Text(usuario.email),
            subtitle: const Text('E-mail'),
          ),
          ListTile(
            leading: const Icon(Icons.verified_user),
            title: Text(usuario.nivelAcesso),
            subtitle: const Text('Nível de Acesso'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.password, color: Colors.blue),
            title: const Text('Redefinir Senha'),
            onTap: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final result = await authService.resetPassword(email: usuario.email);
              scaffoldMessenger.showSnackBar(
                SnackBar(content: Text(result == 'success' 
                  ? 'E-mail de redefinição enviado para ${usuario.email}'
                  : 'Erro: $result')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Sair (Logout)'),
            onTap: () => authService.signOut(),
          ),
        ],
      ),
    );
  }
}