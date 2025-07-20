import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoricoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> registrarAcao({
    required String acao, // Ex: 'criou_ativo', 'deletou_emprestimo'
    required String alvoId, // Ex: ID do ativo, ID do empréstimo
    required String alvoDescricao, // Ex: "Notebook Dell Vostro"
    Map<String, dynamic>? detalhes, // Informações extras
  }) async {
    final user = _auth.currentUser;
    if (user == null) return; // Não registrar se não houver usuário logado

    try {
      await _firestore.collection('historico').add({
        'usuarioId': user.uid,
        'usuarioEmail': user.email,
        'acao': acao,
        'alvoId': alvoId,
        'alvoDescricao': alvoDescricao,
        'detalhes': detalhes,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      ('Erro ao registrar ação no histórico: $e');
    }
  }
}