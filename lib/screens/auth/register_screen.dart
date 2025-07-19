import 'package:flutter/material.dart';
import 'package:stoquer/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() { _isLoading = true; });

    // --- AQUI ESTÁ A CORREÇÃO ---
    // O nome do método correto é 'signUpWithEmail', como definido no AuthService.
    final userCredential = await _authService.signUpWithEmail(
      _emailController.text.trim(),
      _passwordController.text.trim(),
      _nomeController.text.trim(),
    );

    if (!mounted) return;

    setState(() { _isLoading = false; });

    if (userCredential == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Falha no registro. O e-mail pode já estar em uso.'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      // Se o registro for bem-sucedido, o AuthWrapper vai navegar automaticamente.
      // Podemos fechar a tela de registro para o usuário não voltar para ela.
      if(Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar Conta')),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nomeController,
                    decoration: const InputDecoration(
                      labelText: 'Nome Completo',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Por favor, insira seu nome.' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'E-mail',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Por favor, insira um e-mail válido.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'A senha deve ter pelo menos 6 caracteres.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _isLoading ? null : _register,
                    child: _isLoading
                        ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white))
                        : const Text('Registrar', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}