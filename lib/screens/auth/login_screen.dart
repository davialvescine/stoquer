import 'package:flutter/material.dart';
import 'package:stoquer/services/auth_service.dart';
// Remova os comentários das linhas abaixo quando criar as respectivas telas.
// import 'package:stoquer/screens/auth/register_screen.dart';
// import 'package:stoquer/screens/auth/password_reset_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Chave para identificar e validar o formulário
  final _formKey = GlobalKey<FormState>();

  // Controladores para capturar o texto dos campos
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Instância do nosso serviço de autenticação
  final _authService = AuthService();

  // Variáveis de estado da UI
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  // Limpa os controladores quando o widget é descartado para evitar vazamento de memória
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Função principal para lidar com o processo de login
  Future<void> _login() async {
    // 1. Valida o formulário. Se não for válido, a função para aqui.
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 2. Ativa o estado de carregamento e reconstrói a UI
    setState(() {
      _isLoading = true;
    });

    // 3. Chama o serviço de autenticação para fazer o login
    final userCredential = await _authService.signInWithEmail(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    // 4. CORREÇÃO IMPORTANTE: Checa se o widget ainda está na tela antes de usar o context
    if (!mounted) return;

    // 5. Desativa o estado de carregamento
    setState(() {
      _isLoading = false;
    });

    // 6. Se o resultado for nulo, significa que houve um erro. Mostra a mensagem.
    if (userCredential == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('E-mail ou senha inválidos. Tente novamente.'),
          backgroundColor: Colors.red,
        ),
      );
    }
    // Se o login for bem-sucedido, o AuthWrapper cuidará automaticamente da navegação
    // para a tela principal, então não precisamos fazer nada aqui.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- Título e Subtítulo ---
                  Text(
                    'Bem-vindo de volta!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Faça login para gerenciar seus ativos.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                  const SizedBox(height: 48),

                  // --- Campo de E-mail ---
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'E-mail',
                      hintText: 'seuemail@exemplo.com',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor, insira seu e-mail.';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Por favor, insira um e-mail válido.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // --- Campo de Senha ---
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira sua senha.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),

                  // --- Botão de Esqueci a Senha ---
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Navegar para a tela de recuperação de senha
                        // Navigator.push(context, MaterialPageRoute(builder: (context) => const PasswordResetScreen()));
                         ScaffoldMessenger.of(context).showSnackBar(
                           const SnackBar(content: Text('Tela de recuperação de senha em construção.'))
                         );
                      },
                      child: const Text('Esqueceu a senha?'),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- Botão de Login ---
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _isLoading ? null : _login, // Desabilita o botão durante o loading
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : const Text('Entrar', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 32),

                  // --- Link para Tela de Registro ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Não tem uma conta?"),
                      TextButton(
                        onPressed: () {
                          // Navegar para a tela de registro
                          // Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
                           ScaffoldMessenger.of(context).showSnackBar(
                           const SnackBar(content: Text('Tela de registro em construção.'))
                         );
                        },
                        child: const Text('Cadastre-se'),
                      ),
                    ],
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