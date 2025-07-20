import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stoquer/models/ativo.dart';
import 'package:stoquer/services/historico_service.dart';

class AtivoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'ativos';
  final HistoricoService _historicoService = HistoricoService();

  // Listar todos os ativos
  Stream<List<Ativo>> listarAtivos() {
    return _firestore
        .collection(_collectionPath)
        .orderBy('nome')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Ativo.fromMap(doc.id, doc.data())).toList();
    });
  }

  // Buscar ativo por ID
  Future<Ativo?> buscarAtivoPorId(String id) async {
    try {
      final doc = await _firestore.collection(_collectionPath).doc(id).get();
      if (doc.exists) {
        return Ativo.fromMap(doc.id, doc.data()!);
      }
      return null;
    } catch (e) {
      ('Erro ao buscar ativo: $e');
      return null;
    }
  }

  // Criar novo ativo
  Future<String?> criarAtivo(Ativo ativo) async {
    try {
      final docRef = await _firestore.collection(_collectionPath).add(ativo.toMap());
      await _historicoService.registrarAcao(
        acao: 'criou_ativo',
        alvoId: docRef.id,
        alvoDescricao: ativo.nome,
      );
      return docRef.id;
    } catch (e) {
      ('Erro ao criar ativo: $e');
      return null;
    }
  }

  // Atualizar ativo
  Future<void> atualizarAtivo(Ativo ativo) async {
    try {
      await _firestore.collection(_collectionPath).doc(ativo.id).update(ativo.toMap());
      await _historicoService.registrarAcao(
        acao: 'atualizou_ativo',
        alvoId: ativo.id,
        alvoDescricao: ativo.nome,
      );
    } catch (e) {
      ('Erro ao atualizar ativo: $e');
    }
  }

  // Excluir ativo
  Future<void> excluirAtivo(String id, String nomeAtivo) async {
    try {
      await _firestore.collection(_collectionPath).doc(id).delete();
      await _historicoService.registrarAcao(
        acao: 'excluiu_ativo',
        alvoId: id,
        alvoDescricao: nomeAtivo,
      );
    } catch (e) {
      ('Erro ao excluir ativo: $e');
    }
  }
}