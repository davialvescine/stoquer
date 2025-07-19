import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stoquer/firebase_options.dart';
import 'package:stoquer/models/usuario_model.dart';
import 'package:stoquer/screens/auth/auth_wrapper.dart';
import 'package:stoquer/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos o StreamProvider para disponibilizar o estado do usuário para todo o app.
    return StreamProvider<UsuarioModel?>.value(
      value: AuthService().usuarioModelStream, // Usando o stream do nosso modelo personalizado
      initialData: null,
      child: MaterialApp(
        title: 'Stoquer',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Inter',
          primarySwatch: Colors.indigo,
          scaffoldBackgroundColor: const Color(0xFFF5F7FA),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 1,
            iconTheme: IconThemeData(color: Colors.black87),
            titleTextStyle: TextStyle(
                color: Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}