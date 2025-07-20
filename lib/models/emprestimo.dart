import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
// Remova imports não utilizados

class EmprestimoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'emprestimos';

  // Método fromRestore que estava faltando
  Future<Emprestimo?> fromRestore(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists && doc.data() != null) {
        return Emprestimo.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      // Use debugPrint ao invés de print
      debugPrint('Erro ao restaurar empréstimo: $e');
      return null;
    }
  }

  // Método toMap que estava faltando
  Future<void> toMap(Emprestimo emprestimo) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(emprestimo.id)
          .set(emprestimo.toMap());
    } catch (e) {
      debugPrint('Erro ao salvar empréstimo: $e');
      rethrow;
    }
  }

  // Método resetPassword que estava faltando
  Future<void> resetPassword(String emprestimoId) async {
    try {
      final emprestimo = await fromRestore(emprestimoId);
      if (emprestimo != null) {
        final resetEmprestimo = emprestimo.resetPassword();
        await toMap(resetEmprestimo);
      }
    } catch (e) {
      debugPrint('Erro ao resetar senha do empréstimo: $e');
      rethrow;
    }
  }

  // Método ativoVolume que estava faltando
  Future<List<Emprestimo>> ativoVolume() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('ativo', isEqualTo: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => Emprestimo.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Erro ao buscar empréstimos ativos: $e');
      return [];
    }
  }

  // Outros métodos necessários
  Future<List<Emprestimo>> getAllEmprestimos() async {
    try {
      final querySnapshot = await _firestore.collection(_collection).get();
      return querySnapshot.docs
          .map((doc) => Emprestimo.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Erro ao buscar todos os empréstimos: $e');
      return [];
    }
  }

  Future<void> updateEmprestimo(Emprestimo emprestimo) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(emprestimo.id)
          .update(emprestimo.toMap());
    } catch (e) {
      debugPrint('Erro ao atualizar empréstimo: $e');
      rethrow;
    }
  }

  Future<void> deleteEmprestimo(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      debugPrint('Erro ao deletar empréstimo: $e');
      rethrow;
    }
  }

  // Stream para atualizações em tempo real
  Stream<List<Emprestimo>> getEmprestimosStream() {
    return _firestore
        .collection(_collection)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Emprestimo.fromMap(doc.data()))
            .toList());
  }
}