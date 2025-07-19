import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stoquer/models/usuario_model.dart'; // Importe nosso novo modelo
import 'dart:async'; // Importe para usar o StreamTransformer

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ESTA É A GRANDE MUDANÇA!
  // O stream agora retorna nosso modelo completo com o nível de acesso.
  Stream<UsuarioModel?> get usuarioModelStream {
    return _auth.authStateChanges().asyncMap((User? user) async {
      if (user == null) {
        return null; // Se não há usuário logado, retorna nulo
      }
      // Se há um usuário, busca seus dados no Firestore
      final doc = await _firestore.collection('usuarios').doc(user.uid).get();
      if (doc.exists) {
        // Cria e retorna nosso modelo personalizado
        return UsuarioModel.fromFirestore(doc);
      }
      return null;
    });
  }

  // O restante do seu AuthService (signIn, signUp, signOut, etc.) continua igual...

  Future<UserCredential?> signInWithEmail(String email, String password) { /* ...código existente... */ }
  Future<UserCredential?> signUpWithEmail(String email, String password, String nome) { /* ...código existente... */ }
  Future<void> signOut() { /* ...código existente... */ }
  Future<void> sendPasswordResetEmail(String email) { /* ...código existente... */ }
}