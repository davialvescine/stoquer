/// ENUM: Status dos Ativos
/// 
/// Define os possíveis estados de um ativo no sistema:
/// - disponivel: Ativo está livre para uso
/// - emprestado: Ativo está emprestado a alguém
/// - emUso: Ativo está sendo usado atualmente
enum AssetStatus { disponivel, emprestado, emUso }

/// MODELO DE ATIVOS - Sistema de Controle de Estoque
/// 
/// Este arquivo define o modelo de dados para os ativos/equipamentos
/// do sistema de controle de estoque Stoquer.
/// 
/// FUNCIONALIDADES:
/// - Armazenar informações completas de ativos
/// - Suporte a múltiplas fotos por ativo
/// - Controle de status (disponível, emprestado, em uso)
/// - Anexo de nota fiscal
/// - Registro de datas de criação e atualização
/// - Conversão para/de Map para Firebase
/// 
/// Representa um ativo/equipamento no sistema de controle de estoque.
/// Contém todas as informações necessárias para controlar um item.
class Asset {
  // ID único do ativo (imutável após criação)
  final String id;
  
  // Nome/título do ativo (ex: "Notebook Dell", "Projetor Epson")
  String titulo;
  
  // Lista de URLs das fotos do ativo (Firebase Storage)
  List<String> fotosUrls;
  
  // ID da categoria a qual o ativo pertence
  String categoriaId;
  
  // ID da localização onde o ativo está armazenado
  String localizacaoId;
  
  // Status atual do ativo (disponível, emprestado, em uso)
  AssetStatus status;
  
  // Define se é um acessório (true) ou ativo principal (false)
  bool isAcessorio;
  
  // Data de compra do ativo (opcional)
  DateTime? dataCompra;
  
  // URL da nota fiscal do ativo (opcional)
  String? notaFiscalUrl;
  
  // Data de criação do registro no sistema
  DateTime createdAt;
  
  // Data da última atualização do registro
  DateTime updatedAt;

  /// CONSTRUTOR: Asset
  /// 
  /// Cria uma nova instância de Asset com todos os campos necessários.
  /// Campos opcionais recebem valores padrão quando não fornecidos.
  /// 
  /// PARÂMETROS:
  /// - id: ID único do ativo (obrigatório)
  /// - titulo: Nome do ativo (obrigatório)
  /// - fotosUrls: Lista de URLs das fotos (opcional, default: lista vazia)
  /// - categoriaId: ID da categoria (obrigatório)
  /// - localizacaoId: ID da localização (obrigatório)
  /// - status: Status do ativo (obrigatório)
  /// - isAcessorio: Se é acessório (opcional, default: false)
  /// - dataCompra: Data de compra (opcional)
  /// - notaFiscalUrl: URL da nota fiscal (opcional)
  /// - createdAt: Data de criação (opcional, default: agora)
  /// - updatedAt: Data de atualização (opcional, default: agora)
  Asset({
    required this.id,
    required this.titulo,
    List<String>? fotosUrls,
    required this.categoriaId,
    required this.localizacaoId,
    required this.status,
    this.isAcessorio = false,
    this.dataCompra,
    this.notaFiscalUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : fotosUrls = fotosUrls ?? [],
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// FACTORY: Asset.fromMap
  /// 
  /// Cria uma instância de Asset a partir de um Map (dados do Firebase).
  /// Este método é usado para deserializar dados vindos do banco de dados.
  /// 
  /// PARÂMETROS:
  /// - id: ID do documento no Firestore
  /// - data: Map com os dados do ativo
  /// 
  /// RETORNO:
  /// - Asset: Nova instância preenchida com os dados do Map
  /// 
  /// TRATAMENTO DE ERROS:
  /// - Valores nulos são tratados com valores padrão
  /// - Compatibilidade com formato antigo (imagemUrl -> fotosUrls)
  /// - Conversão segura de tipos com casting
  factory Asset.fromMap(String id, Map<String, dynamic> data) {
    return Asset(
      id: id,
      titulo: data['titulo'] as String? ?? '',
      // Compatibilidade: se não existir fotosUrls, usa imagemUrl do formato antigo
      fotosUrls: data['fotosUrls'] != null 
          ? List<String>.from(data['fotosUrls'] as List) 
          : (data['imagemUrl'] != null ? [data['imagemUrl'] as String] : []),
      categoriaId: data['categoriaId'] as String? ?? '',
      localizacaoId: data['localizacaoId'] as String? ?? '',
      // Busca o status correto ou usa disponível como padrão
      status: AssetStatus.values.firstWhere(
        (e) => e.toString() == data['status'],
        orElse: () => AssetStatus.disponivel,
      ),
      isAcessorio: data['isAcessorio'] as bool? ?? false,
      // Conversão segura de String para DateTime
      dataCompra: data['dataCompra'] != null 
          ? DateTime.parse(data['dataCompra'] as String) 
          : null,
      notaFiscalUrl: data['notaFiscalUrl'] as String?,
      createdAt: data['createdAt'] != null 
          ? DateTime.parse(data['createdAt'] as String) 
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null 
          ? DateTime.parse(data['updatedAt'] as String) 
          : DateTime.now(),
    );
  }

  /// MÉTODO: toMap
  /// 
  /// Converte a instância de Asset para um Map (para salvar no Firebase).
  /// Este método é usado para serializar dados antes de enviar ao banco.
  /// 
  /// RETORNO:
  /// - Map com String, dynamic: Representação do Asset como Map
  /// 
  /// OBSERVAÇÕES:
  /// - updatedAt é sempre atualizado para o momento atual
  /// - Datas são convertidas para formato ISO 8601
  /// - Status é convertido para String
  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'fotosUrls': fotosUrls,
      'categoriaId': categoriaId,
      'localizacaoId': localizacaoId,
      'status': status.toString(),
      'isAcessorio': isAcessorio,
      'dataCompra': dataCompra?.toIso8601String(),
      'notaFiscalUrl': notaFiscalUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(), // Sempre atualiza para agora
    };
  }

  /// GETTER: statusDisplayName
  /// 
  /// Retorna o nome do status em português para exibição na interface.
  /// 
  /// RETORNO:
  /// - String: Nome do status traduzido para português
  String get statusDisplayName {
    switch (status) {
      case AssetStatus.disponivel:
        return 'Disponível';
      case AssetStatus.emprestado:
        return 'Emprestado';
      case AssetStatus.emUso:
        return 'Em Uso';
    }
  }

  /// GETTER: fotoPrincipal
  /// 
  /// Retorna a URL da primeira foto da lista para usar como thumbnail.
  /// 
  /// RETORNO:
  /// - String?: URL da primeira foto ou null se não houver fotos
  String? get fotoPrincipal => fotosUrls.isNotEmpty ? fotosUrls.first : null;
  
  /// MÉTODO: adicionarFoto
  /// 
  /// Adiciona uma nova foto à lista de fotos do ativo.
  /// Atualiza automaticamente a data de modificação.
  /// 
  /// PARÂMETROS:
  /// - url: URL da foto a ser adicionada
  void adicionarFoto(String url) {
    fotosUrls.add(url);
    updatedAt = DateTime.now();
  }
  
  /// MÉTODO: removerFoto
  /// 
  /// Remove uma foto específica da lista de fotos do ativo.
  /// Atualiza automaticamente a data de modificação.
  /// 
  /// PARÂMETROS:
  /// - url: URL da foto a ser removida
  void removerFoto(String url) {
    fotosUrls.remove(url);
    updatedAt = DateTime.now();
  }
}