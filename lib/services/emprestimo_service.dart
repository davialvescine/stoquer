// lib/services/emprestimo_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stoquer/models/emprestimo.dart';
import 'package:stoquer/services/historico_service.dart';

class EmprestimoService {
  final CollectionReference _emprestimos = FirebaseFirestore.instance.collection('emprestimos');
  final CollectionReference _ativos = FirebaseFirestore.instance.collection('ativos');
  final HistoricoService _historico = HistoricoService();

  Stream<List<Emprestimo>> listarEmprestimosAtivos() {
    return _emprestimos.where('status', isEqualTo: 'ativo')
        .orderBy('dataPrevistaDevolucao').snapshots()
        .map((s) => s.docs.map((d) => Emprestimo.fromFirestore(d)).toList());
  }

  Future<void> devolverEmprestimo(String emprestimoId, String ativoId, String ativoNome) async {
    try {
      await FirebaseFirestore.instance.runTransaction((t) async {
        t.update(_emprestimos.doc(emprestimoId), {'status': 'devolvido', 'dataDevolucaoReal': Timestamp.now()});
        t.update(_ativos.doc(ativoId), {'disponivel': true, 'emprestimoAtualId': null});
      });
      await _historico.registrarAcao(acao: 'devolveu_emprestimo', alvoId: emprestimoId, alvoDescricao: 'Devolucao do ativo: $ativoNome');
    } catch (e) { rethrow; }
  }
  
  // Adicione aqui o método de criar empréstimo que o seu diálogo vai precisar
  Future<void> criarEmprestimo(Emprestimo novoEmprestimo) async {
    try {
      await FirebaseFirestore.instance.runTransaction((t) async {
        DocumentReference empRef = _emprestimos.doc();
        t.set(empRef, novoEmprestimo.copyWith(id: empRef.id).toMap());
        t.update(_ativos.doc(novoEmprestimo.ativoId), {'disponivel': false, 'emprestimoAtualId': empRef.id});
      });
      await _historico.registrarAcao(acao: 'criou_emprestimo', alvoId: novoEmprestimo.id, alvoDescricao: 'Empréstimo do ativo: ${novoEmprestimo.ativoNome}');
    } catch (e) { rethrow; }
  }
}