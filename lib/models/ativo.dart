class Ativo {
  final String id;
  final String codigo;
  final String nome;
  final String categoria;
  final String descricao;
  final bool disponivel;
  final String? emprestimoAtualId;
  final DateTime dataCadastro;
  final String? localizacao;
  final String? numeroSerie;
  final double? valorEstimado;
  final String? condicao; // 'novo', 'bom', 'regular', 'ruim'

  Ativo({
    required this.id,
    required this.codigo,
    required this.nome,
    required this.categoria,
    required this.descricao,
    required this.disponivel,
    this.emprestimoAtualId,
    required this.dataCadastro,
    this.localizacao,
    this.numeroSerie,
    this.valorEstimado,
    this.condicao,
  });

  Map<String, dynamic> toMap() {
    return {
      'codigo': codigo,
      'nome': nome,
      'categoria': categoria,
      'descricao': descricao,
      'disponivel': disponivel,
      'emprestimoAtualId': emprestimoAtualId,
      'dataCadastro': dataCadastro.toIso8601String(),
      'localizacao': localizacao,
      'numeroSerie': numeroSerie,
      'valorEstimado': valorEstimado,
      'condicao': condicao,
    };
  }

  factory Ativo.fromMap(String id, Map<String, dynamic> map) {
    return Ativo(
      id: id,
      codigo: map['codigo'] ?? '',
      nome: map['nome'] ?? '',
      categoria: map['categoria'] ?? '',
      descricao: map['descricao'] ?? '',
      disponivel: map['disponivel'] ?? true,
      emprestimoAtualId: map['emprestimoAtualId'],
      dataCadastro: map['dataCadastro'] != null ? DateTime.parse(map['dataCadastro']) : DateTime.now(),
      localizacao: map['localizacao'],
      numeroSerie: map['numeroSerie'],
      valorEstimado: (map['valorEstimado'] as num?)?.toDouble(),
      condicao: map['condicao'],
    );
  }
}