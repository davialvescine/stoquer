import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stoquer/models/usuario_model.dart';
import 'package:stoquer/services/auth_service.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos o Provider para pegar as informações do usuário que está logado.
    final usuario = Provider.of<UsuarioModel?>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          // Botão de Logout (Sair)
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () {
              // Chama o método signOut do nosso serviço de autenticação
              AuthService().signOut();
              // O AuthWrapper cuidará de redirecionar para a tela de login.
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              // Se o usuário não for nulo, mostra o nome dele.
              'Bem-vindo(a), ${usuario?.nome ?? 'Usuário'}!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Text(
              'Seu nível de acesso é: ${usuario?.nivelAcesso ?? 'indefinido'}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}