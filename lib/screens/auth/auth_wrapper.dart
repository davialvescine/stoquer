import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stoquer/models/usuario_model.dart';
import 'package:stoquer/screens/dashboard_screen.dart'; // Tela principal após login
import 'package:stoquer/screens/auth/welcome_screen.dart'; // Tela de boas-vindas/login

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Consome o UsuarioModel do StreamProvider no main.dart
    final usuario = Provider.of<UsuarioModel?>(context);

    // Se o usuário não for nulo, significa que está logado.
    if (usuario != null) {
      // Vá para a tela principal
      return const DashboardScreen(); // Crie esta tela se ainda não existir
    } else {
      // Caso contrário, mostre a tela de boas-vindas/login
      return const WelcomeScreen(); // Crie esta tela se ainda não existir
    }
  }
}