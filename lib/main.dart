import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 1. Importar o Provider
import 'package:firebase_auth/firebase_auth.dart'; // 2. Importar o Firebase Auth para o tipo User

import 'firebase_options.dart';
import 'screens/auth/auth_wrapper.dart';
import 'services/auth_service.dart'; // 3. Importar seu AuthService

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
    // 4. Envolver o MaterialApp com o StreamProvider
    return StreamProvider<User?>.value(
      value: AuthService().user, // O stream que será "ouvido"
      initialData: null, // O valor inicial antes do stream emitir o primeiro dado
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
            titleTextStyle: TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}