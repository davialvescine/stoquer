// lib/services/emprestimo_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/emprestimo.dart';

class EmprestimoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // A coleção de empréstimos no Firestore
  // SOLUÇÃO: A lógica do `withConverter` foi ajustada para ser compatível
  // com o seu modelo `Emprestimo.fromMap`.
  CollectionReference<Emprestimo> get _emprestimosCollection =>
      _firestore.collection('emprestimos').withConverter<Emprestimo>(
            fromFirestore: (snapshot, _) => Emprestimo.fromMap(snapshot.id, snapshot.data()!),
            toFirestore: (emprestimo, _) => emprestimo.toMap(),
          );

  // Criar um novo empréstimo
  Future<void> criarEmprestimo(Emprestimo novoEmprestimo) async {
    try {
      await _emprestimosCollection.add(novoEmprestimo);
    } catch (e) {
      debugPrint('Erro ao criar empréstimo: $e');
      rethrow;
    }
  }

  // Atualizar o status de um empréstimo para 'devolvido'
  Future<void> devolverEmprestimo(String emprestimoId) async {
    try {
      await _emprestimosCollection.doc(emprestimoId).update({
        'status': 'devolvido',
        'dataDevolucaoReal': Timestamp.now(),
      });
    } catch (e) {
      debugPrint('Erro ao devolver empréstimo: $e');
      rethrow;
    }
  }
  
  // Stream para ouvir mudanças nos empréstimos em tempo real
  Stream<List<Emprestimo>> getEmprestimosStream() {
    return _emprestimosCollection
        .orderBy('dataEmprestimo', descending: true)
        .snapshots()
        .map(
          // Esta parte já está correta graças ao withConverter
          (snapshot) => snapshot.docs.map((doc) => doc.data()).toList(),
        );
  }
}