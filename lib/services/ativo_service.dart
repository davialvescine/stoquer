// services/ativo_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ativo.dart';
import 'historico_service.dart'; // 1. IMPORTAR O NOVO SERVIÇO

class AtivoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collection = 'ativos';
  
  // 2. INSTANCIAR O SERVIÇO DE HISTÓRICO
  final HistoricoService _historicoService = HistoricoService();

  // Listar todos os ativos (nenhuma mudança necessária aqui)
  Stream<List<Ativo>> listarAtivos() {
    return _firestore
        .collection(collection)
        .orderBy('nome')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Ativo.fromMap(data);
      }).toList();
    });
  }

  // Listar apenas ativos disponíveis (nenhuma mudança necessária aqui)
  Stream<List<Ativo>> listarAtivosDisponiveis() {
    return _firestore
        .collection(collection)
        .where('disponivel', isEqualTo: true)
        .orderBy('nome')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Ativo.fromMap(data);
      }).toList();
    });
  }

  // Buscar ativo por ID (nenhuma mudança necessária aqui)
  Future<Ativo?> buscarAtivoPorId(String id) async {
    try {
      final doc = await _firestore.collection(collection).doc(id).get();
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return Ativo.fromMap(data);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar ativo: $e');
    }
  }

  // Criar novo ativo
  Future<String> criarAtivo(Ativo ativo) async {
    try {
      final data = ativo.toMap();
      // O ID é gerado pelo Firestore, então é bom removê-lo antes de enviar.
      data.remove('id'); 
      final docRef = await _firestore.collection(collection).add(data);

      // 3. REGISTRAR A AÇÃO DE CRIAÇÃO
      await _historicoService.registrarAcao(
        acao: 'criou_ativo',
        alvoId: docRef.id,
        alvoDescricao: ativo.nome, // Usa o nome do ativo para um log claro
      );

      return docRef.id;
    } catch (e) {
      throw Exception('Erro ao criar ativo: $e');
    }
  }

  // Atualizar ativo
  Future<void> atualizarAtivo(Ativo ativo) async {
    try {
      await _firestore
          .collection(collection)
          .doc(ativo.id)
          .update(ativo.toMap());

      // 3. REGISTRAR A AÇÃO DE ATUALIZAÇÃO
      await _historicoService.registrarAcao(
        acao: 'atualizou_ativo',
        alvoId: ativo.id,
        alvoDescricao: ativo.nome,
        // Opcional: você pode adicionar mais detalhes sobre o que mudou
        // detalhes: {'campos_alterados': ['condicao', 'localizacao']} 
      );

    } catch (e) {
      throw Exception('Erro ao atualizar ativo: $e');
    }
  }

  // Excluir ativo
  // 4. MODIFICADO PARA ACEITAR O NOME DO ATIVO PARA O LOG
  Future<void> excluirAtivo(String id, String nomeAtivo) async {
    try {
      await _firestore.collection(collection).doc(id).delete();

      // 3. REGISTRAR A AÇÃO DE EXCLUSÃO
      await _historicoService.registrarAcao(
        acao: 'excluiu_ativo',
        alvoId: id,
        alvoDescricao: nomeAtivo, // Usa a variável recebida
      );

    } catch (e) {
      throw Exception('Erro ao excluir ativo: $e');
    }
  }
}