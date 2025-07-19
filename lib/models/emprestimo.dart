// models/emprestimo.dart
class Emprestimo {
  final String id;
  final String ativoId;
  final String nomeAtivo;
  final String solicitante;
  final String emailSolicitante;
  final String telefone;
  final DateTime dataEmprestimo;
  final DateTime? dataDevolucaoPrevista;
  final DateTime? dataDevolucaoReal;
  final String status; // 'ativo', 'devolvido', 'atrasado'
  final String? observacoes;
  final String responsavelEmprestimo;
  final String? responsavelDevolucao;

  Emprestimo({
    required this.id,
    required this.ativoId,
    required this.nomeAtivo,
    required this.solicitante,
    required this.emailSolicitante,
    required this.telefone,
    required this.dataEmprestimo,
    this.dataDevolucaoPrevista,
    this.dataDevolucaoReal,
    required this.status,
    this.observacoes,
    required this.responsavelEmprestimo,
    this.responsavelDevolucao,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ativoId': ativoId,
      'nomeAtivo': nomeAtivo,
      'solicitante': solicitante,
      'emailSolicitante': emailSolicitante,
      'telefone': telefone,
      'dataEmprestimo': dataEmprestimo.toIso8601String(),
      'dataDevolucaoPrevista': dataDevolucaoPrevista?.toIso8601String(),
      'dataDevolucaoReal': dataDevolucaoReal?.toIso8601String(),
      'status': status,
      'observacoes': observacoes,
      'responsavelEmprestimo': responsavelEmprestimo,
      'responsavelDevolucao': responsavelDevolucao,
    };
  }

  factory Emprestimo.fromMap(Map<String, dynamic> map) {
    return Emprestimo(
      id: map['id'] ?? '',
      ativoId: map['ativoId'] ?? '',
      nomeAtivo: map['nomeAtivo'] ?? '',
      solicitante: map['solicitante'] ?? '',
      emailSolicitante: map['emailSolicitante'] ?? '',
      telefone: map['telefone'] ?? '',
      dataEmprestimo: DateTime.parse(map['dataEmprestimo']),
      dataDevolucaoPrevista: map['dataDevolucaoPrevista'] != null
          ? DateTime.parse(map['dataDevolucaoPrevista'])
          : null,
      dataDevolucaoReal: map['dataDevolucaoReal'] != null
          ? DateTime.parse(map['dataDevolucaoReal'])
          : null,
      status: map['status'] ?? 'ativo',
      observacoes: map['observacoes'],
      responsavelEmprestimo: map['responsavelEmprestimo'] ?? '',
      responsavelDevolucao: map['responsavelDevolucao'],
    );
  }

  Emprestimo copyWith({
    String? id,
    String? ativoId,
    String? nomeAtivo,
    String? solicitante,
    String? emailSolicitante,
    String? telefone,
    DateTime? dataEmprestimo,
    DateTime? dataDevolucaoPrevista,
    DateTime? dataDevolucaoReal,
    String? status,
    String? observacoes,
    String? responsavelEmprestimo,
    String? responsavelDevolucao,
  }) {
    return Emprestimo(
      id: id ?? this.id,
      ativoId: ativoId ?? this.ativoId,
      nomeAtivo: nomeAtivo ?? this.nomeAtivo,
      solicitante: solicitante ?? this.solicitante,
      emailSolicitante: emailSolicitante ?? this.emailSolicitante,
      telefone: telefone ?? this.telefone,
      dataEmprestimo: dataEmprestimo ?? this.dataEmprestimo,
      dataDevolucaoPrevista: dataDevolucaoPrevista ?? this.dataDevolucaoPrevista,
      dataDevolucaoReal: dataDevolucaoReal ?? this.dataDevolucaoReal,
      status: status ?? this.status,
      observacoes: observacoes ?? this.observacoes,
      responsavelEmprestimo: responsavelEmprestimo ?? this.responsavelEmprestimo,
      responsavelDevolucao: responsavelDevolucao ?? this.responsavelDevolucao,
    );
  }
}
