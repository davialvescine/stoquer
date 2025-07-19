// services/emprestimo_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/emprestimo.dart';

class EmprestimoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collection = 'emprestimos';

  // Criar novo empréstimo
  Future<String> criarEmprestimo(Emprestimo emprestimo) async {
    try {
      final docRef = await _firestore.collection(collection).add(emprestimo.toMap());
      
      // Atualizar status do ativo para "emprestado"
      await _firestore.collection('ativos').doc(emprestimo.ativoId).update({
        'disponivel': false,
        'emprestimoAtualId': docRef.id,
      });
      
      return docRef.id;
    } catch (e) {
      throw Exception('Erro ao criar empréstimo: $e');
    }
  }

  // Listar todos os empréstimos
  Stream<List<Emprestimo>> listarEmprestimos() {
    return _firestore
        .collection(collection)
        .orderBy('dataEmprestimo', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Emprestimo.fromMap(data);
      }).toList();
    });
  }

  // Listar empréstimos ativos
  Stream<List<Emprestimo>> listarEmprestimosAtivos() {
    return _firestore
        .collection(collection)
        .where('status', isEqualTo: 'ativo')
        .orderBy('dataEmprestimo', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Emprestimo.fromMap(data);
      }).toList();
    });
  }

  // Buscar empréstimo por ID
  Future<Emprestimo?> buscarEmprestimoPorId(String id) async {
    try {
      final doc = await _firestore.collection(collection).doc(id).get();
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return Emprestimo.fromMap(data);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar empréstimo: $e');
    }
  }

  // Devolver empréstimo
  Future<void> devolverEmprestimo(String emprestimoId, String responsavelDevolucao) async {
    try {
      final emprestimo = await buscarEmprestimoPorId(emprestimoId);
      if (emprestimo == null) {
        throw Exception('Empréstimo não encontrado');
      }

      // Atualizar empréstimo
      await _firestore.collection(collection).doc(emprestimoId).update({
        'status': 'devolvido',
        'dataDevolucaoReal': DateTime.now().toIso8601String(),
        'responsavelDevolucao': responsavelDevolucao,
      });

      // Atualizar status do ativo para "disponível"
      await _firestore.collection('ativos').doc(emprestimo.ativoId).update({
        'disponivel': true,
        'emprestimoAtualId': null,
      });
    } catch (e) {
      throw Exception('Erro ao devolver empréstimo: $e');
    }
  }

  // Atualizar empréstimo
  Future<void> atualizarEmprestimo(Emprestimo emprestimo) async {
    try {
      await _firestore
          .collection(collection)
          .doc(emprestimo.id)
          .update(emprestimo.toMap());
    } catch (e) {
      throw Exception('Erro ao atualizar empréstimo: $e');
    }
  }

  // Verificar e atualizar empréstimos atrasados
  Future<void> verificarEmprestimosAtrasados() async {
    try {
      final agora = DateTime.now();
      final querySnapshot = await _firestore
          .collection(collection)
          .where('status', isEqualTo: 'ativo')
          .get();

      for (var doc in querySnapshot.docs) {
        final emprestimo = Emprestimo.fromMap({...doc.data(), 'id': doc.id});
        
        if (emprestimo.dataDevolucaoPrevista != null &&
            emprestimo.dataDevolucaoPrevista!.isBefore(agora)) {
          await doc.reference.update({'status': 'atrasado'});
        }
      }
    } catch (e) {
      throw Exception('Erro ao verificar empréstimos atrasados: $e');
    }
  }

  // Buscar histórico de empréstimos por ativo
  Stream<List<Emprestimo>> buscarHistoricoPorAtivo(String ativoId) {
    return _firestore
        .collection(collection)
        .where('ativoId', isEqualTo: ativoId)
        .orderBy('dataEmprestimo', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Emprestimo.fromMap(data);
      }).toList();
    });
  }

  // Buscar empréstimos por solicitante
  Stream<List<Emprestimo>> buscarEmprestimosPorSolicitante(String solicitante) {
    return _firestore
        .collection(collection)
        .where('solicitante', isEqualTo: solicitante)
        .orderBy('dataEmprestimo', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Emprestimo.fromMap(data);
      }).toList();
    });
  }

  // Estatísticas de empréstimos
  Future<Map<String, dynamic>> obterEstatisticas() async {
    try {
      final querySnapshot = await _firestore.collection(collection).get();
      
      int totalEmprestimos = querySnapshot.docs.length;
      int emprestimosAtivos = 0;
      int emprestimosDevolvidos = 0;
      int emprestimosAtrasados = 0;

      for (var doc in querySnapshot.docs) {
        final status = doc.data()['status'];
        switch (status) {
          case 'ativo':
            emprestimosAtivos++;
            break;
          case 'devolvido':
            emprestimosDevolvidos++;
            break;
          case 'atrasado':
            emprestimosAtrasados++;
            break;
        }
      }

      return {
        'total': totalEmprestimos,
        'ativos': emprestimosAtivos,
        'devolvidos': emprestimosDevolvidos,
        'atrasados': emprestimosAtrasados,
      };
    } catch (e) {
      throw Exception('Erro ao obter estatísticas: $e');
    }
  }
}

