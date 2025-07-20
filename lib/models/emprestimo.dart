// lib/models/emprestimo.dart

import 'package:cloud_firestore/cloud_firestore.dart';

// SOLUÇÃO: Esta é a classe de MODELO de dados que estava faltando no projeto.
// Todos os outros arquivos que usam 'Emprestimo' agora conseguirão encontrá-la.
class Emprestimo {
  final String id;
  final String ativoId;
  final String ativoNome;
  final String usuarioId;
  final String usuarioNome;
  final DateTime dataEmprestimo;
  final DateTime dataPrevistaDevolucao;
  final DateTime? dataDevolucaoReal; // Nulável, pois só existe quando devolvido
  final String status; // Ex: 'ativo', 'devolvido'
  final String responsavelEmprestimo; // ID ou nome de quem registrou

  Emprestimo({
    required this.id,
    required this.ativoId,
    required this.ativoNome,
    required this.usuarioId,
    required this.usuarioNome,
    required this.dataEmprestimo,
    required this.dataPrevistaDevolucao,
    this.dataDevolucaoReal,
    required this.status,
    required this.responsavelEmprestimo,
  });

  // Converte um Documento do Firestore em um objeto Emprestimo
  factory Emprestimo.fromMap(String id, Map<String, dynamic> data) {
    return Emprestimo(
      id: id,
      ativoId: data['ativoId'] ?? '',
      ativoNome: data['ativoNome'] ?? '',
      usuarioId: data['usuarioId'] ?? '',
      usuarioNome: data['usuarioNome'] ?? '',
      dataEmprestimo: (data['dataEmprestimo'] as Timestamp).toDate(),
      dataPrevistaDevolucao: (data['dataPrevistaDevolucao'] as Timestamp).toDate(),
      dataDevolucaoReal: data['dataDevolucaoReal'] != null
          ? (data['dataDevolucaoReal'] as Timestamp).toDate()
          : null,
      status: data['status'] ?? 'desconhecido',
      responsavelEmprestimo: data['responsavelEmprestimo'] ?? '',
    );
  }

  // Converte um objeto Emprestimo em um Mapa para o Firestore
  Map<String, dynamic> toMap() {
    return {
      'ativoId': ativoId,
      'ativoNome': ativoNome,
      'usuarioId': usuarioId,
      'usuarioNome': usuarioNome,
      'dataEmprestimo': Timestamp.fromDate(dataEmprestimo),
      'dataPrevistaDevolucao': Timestamp.fromDate(dataPrevistaDevolucao),
      'dataDevolucaoReal': dataDevolucaoReal != null
          ? Timestamp.fromDate(dataDevolucaoReal!)
          : null,
      'status': status,
      'responsavelEmprestimo': responsavelEmprestimo,
    };
  }
}