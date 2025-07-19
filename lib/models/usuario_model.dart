import 'package:cloud_firestore/cloud_firestore.dart';

class UsuarioModel {
  final String uid;
  final String email;
  final String nome;
  final String nivelAcesso; // 'admin' ou 'usuario'

  UsuarioModel({
    required this.uid,
    required this.email,
    required this.nome,
    required this.nivelAcesso,
  });

  // Um "construtor" que cria um UsuarioModel a partir de um documento do Firestore
  factory UsuarioModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return UsuarioModel(
      uid: doc.id,
      email: data['email'] ?? '',
      nome: data['nome'] ?? '',
      nivelAcesso: data['nivelAcesso'] ?? 'usuario', // Garante 'usuario' como padrão
    );
  }
}