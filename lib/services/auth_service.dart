// lib/services/auth_service.dart
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
    } catch (e) { return null; }
  }

  Future<UserCredential?> signUpWithEmail(String email, String password, String nome) async {
    try {
      UserCredential uc = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await _firestore.collection('usuarios').doc(uc.user!.uid).set({
        'uid': uc.user!.uid, 'nome': nome, 'email': email,
        'nivelAcesso': 'usuario', 'dataCriacao': Timestamp.now(),
      });
      return uc;
    } catch (e) { return null; }
  }

  Future<void> signOut() async => await _auth.signOut();
  
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) { print("Erro ao resetar senha: $e"); }
  }
}