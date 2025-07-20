// lib/services/auth_service.dart
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // Adicionado para usar debugPrint
import 'package:stoquer/models/usuario_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<UsuarioModel?> get usuarioModelStream {
    return _auth.authStateChanges().asyncMap((User? user) async {
      if (user == null) return null;
      final doc = await _firestore.collection('usuarios').doc(user.uid).get();
      return doc.exists ? UsuarioModel.fromFirestore(doc) : null;
    });
  }

  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      debugPrint("Erro ao fazer login: $e");
      return null;
    }
  }

  Future<UserCredential?> signUpWithEmail(String email, String password, String nome) async {
    try {
      UserCredential uc = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await _firestore.collection('usuarios').doc(uc.user!.uid).set({
        'uid': uc.user!.uid, 'nome': nome, 'email': email,
        'nivelAcesso': 'usuario', 'dataCriacao': Timestamp.now(),
      });
      return uc;
    } catch (e) {
      debugPrint("Erro ao criar usuário: $e");
      return null;
    }
  }

  Future<void> signOut() async => await _auth.signOut();
  
  // SOLUÇÃO: Método `resetPassword` adicionado para ser chamado pela tela de perfil.
  Future<String?> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return 'success';
    } on FirebaseAuthException catch (e) {
      debugPrint("Erro ao resetar senha: $e");
      return e.message; // Retorna a mensagem de erro do Firebase
    } catch (e) {
      debugPrint("Erro desconhecido ao resetar senha: $e");
      return 'Ocorreu um erro inesperado.';
    }
  }
}