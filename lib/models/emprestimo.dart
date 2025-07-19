// lib/models/emprestimo.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Emprestimo {
  final String id;
  final String ativoId;
  final String usuarioId;
  final String ativoNome;
  final String usuarioNome;
  final DateTime dataEmprestimo;
  final DateTime dataPrevistaDevolucao;
  final DateTime? dataDevolucaoReal;
  final String status; // 'ativo', 'devolvido', 'atrasado'
  final String? observacoes;
  final String responsavelEmprestimo;
  final String? responsavelDevolucao;

  Emprestimo({
    required this.id,
    required this.ativoId,
    required this.usuarioId,
    required this.ativoNome,
    required this.usuarioNome,
    required this.dataEmprestimo,
    required this.dataPrevistaDevolucao,
    this.dataDevolucaoReal,
    required this.status,
    this.observacoes,
    required this.responsavelEmprestimo,
    this.responsavelDevolucao,
  });

  Map<String, dynamic> toMap() {
    return {
      'ativoId': ativoId, 'usuarioId': usuarioId, 'ativoNome': ativoNome,
      'usuarioNome': usuarioNome, 'dataEmprestimo': Timestamp.fromDate(dataEmprestimo),
      'dataPrevistaDevolucao': Timestamp.fromDate(dataPrevistaDevolucao),
      'dataDevolucaoReal': dataDevolucaoReal != null ? Timestamp.fromDate(dataDevolucaoReal!) : null,
      'status': status, 'observacoes': observacoes,
      'responsavelEmprestimo': responsavelEmprestimo, 'responsavelDevolucao': responsavelDevolucao,
    };
  }

  factory Emprestimo.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Emprestimo(
      id: doc.id, ativoId: data['ativoId'] ?? '', usuarioId: data['usuarioId'] ?? '',
      ativoNome: data['ativoNome'] ?? '', usuarioNome: data['usuarioNome'] ?? '',
      dataEmprestimo: (data['dataEmprestimo'] as Timestamp).toDate(),
      dataPrevistaDevolucao: (data['dataPrevistaDevolucao'] as Timestamp).toDate(),
      dataDevolucaoReal: (data['dataDevolucaoReal'] as Timestamp?)?.toDate(),
      status: data['status'] ?? 'ativo', observacoes: data['observacoes'],
      responsavelEmprestimo: data['responsavelEmprestimo'] ?? '',
      responsavelDevolucao: data['responsavelDevolucao'],
    );
  }
}