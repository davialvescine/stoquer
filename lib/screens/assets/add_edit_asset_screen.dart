/**
 * TELA DE ADICIONAR/EDITAR ATIVO
 * 
 * Esta tela permite criar novos ativos ou editar ativos existentes
 * no sistema de controle de estoque Stoquer.
 * 
 * FUNCIONALIDADES PRINCIPAIS:
 * - Criar novo ativo ou editar ativo existente
 * - Upload de múltiplas fotos (câmera ou galeria)
 * - Seleção de categoria e localização
 * - Anexar nota fiscal
 * - Definir data de compra
 * - Controlar status do ativo
 * - Validação completa dos dados
 */

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/asset_model.dart';
import '../../models/category_model.dart';
import '../../models/location_model.dart';
import '../../services/firestore_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

/**
 * WIDGET PRINCIPAL: AddEditAssetScreen
 * 
 * StatefulWidget que gerencia a tela de adicionar/editar ativos.
 * Pode operar em dois modos: criação (asset = null) ou edição (asset != null).
 */
class AddEditAssetScreen extends StatefulWidget {
  // Ativo a ser editado (null para criar novo)
  final Asset? asset;
  
  // Define se é um acessório (true) ou ativo principal (false)
  final bool isAcessorio;

  /**
   * CONSTRUTOR: AddEditAssetScreen
   * 
   * PARÂMETROS:
   * - asset: Ativo a ser editado (opcional, null para criar novo)
   * - isAcessorio: Se true, cria/edita acessório; se false, ativo principal
   */
  const AddEditAssetScreen({
    super.key,
    this.asset,
    required this.isAcessorio,
  });

  @override
  State<AddEditAssetScreen> createState() => _AddEditAssetScreenState();
}

/**
 * ESTADO DA TELA: _AddEditAssetScreenState
 * 
 * Gerencia todo o estado da tela de adicionar/editar ativos.
 * Controla formulário, imagens, dados e interações do usuário.
 */
class _AddEditAssetScreenState extends State<AddEditAssetScreen> {
  // === CONTROLADORES DE FORMULÁRIO ===
  // Chave global para validação do formulário
  final _formKey = GlobalKey<FormState>();
  
  // Controlador para o campo de título/nome do ativo
  final _tituloController = TextEditingController();
  
  // === SERVIÇOS ===
  // Serviço para operações no Firestore (banco de dados)
  final _firestoreService = FirestoreService();
  
  // Serviço para upload de arquivos no Firebase Storage
  final _storageService = StorageService();
  
  // Serviço para capturar imagens (câmera/galeria)
  final _imagePicker = ImagePicker();

  // === CONTROLE DE IMAGENS ===
  // Lista de novas imagens selecionadas pelo usuário (arquivos locais)
  final List<File> _selectedImages = [];
  
  // Lista de URLs das imagens já existentes (do Firebase Storage)
  List<String> _existingImageUrls = [];
  
  // Arquivo local da nova nota fiscal selecionada
  File? _notaFiscalFile;
  
  // URL da nota fiscal existente (se editando ativo)
  String? _existingNotaFiscalUrl;
  
  // === DADOS DO FORMULÁRIO ===
  // ID da categoria selecionada
  String? _selectedCategoryId;
  
  // ID da localização selecionada
  String? _selectedLocationId;
  
  // Status do ativo (disponível, emprestado, em uso)
  AssetStatus _selectedStatus = AssetStatus.disponivel;
  
  // Data de compra do ativo (opcional)
  DateTime? _dataCompra;
  
  // === LISTAS DE OPÇÕES ===
  // Lista de categorias disponíveis (carregada do Firestore)
  List<Category> _categories = [];
  
  // Lista de localizações disponíveis (carregada do Firestore)
  List<Location> _locations = [];
  
  // === CONTROLE DE ESTADO DA UI ===
  // Indica se alguma operação está em andamento (loading)
  bool _isLoading = false;

  /**
   * MÉTODO DO CICLO DE VIDA: initState
   * 
   * Executado quando o widget é criado pela primeira vez.
   * Inicializa os dados necessários para a tela.
   * 
   * AÇÕES REALIZADAS:
   * - Carrega categorias e localizações do Firestore
   * - Se editando ativo existente, popula os campos com os dados
   */
  @override
  void initState() {
    super.initState();
    _loadInitialData();
    if (widget.asset != null) {
      _populateFields();
    }
  }

  /**
   * MÉTODO: _populateFields
   * 
   * Popula todos os campos do formulário com os dados do ativo existente.
   * Usado apenas no modo de edição (quando widget.asset != null).
   * 
   * CAMPOS POPULADOS:
   * - Título do ativo
   * - Categoria e localização selecionadas
   * - Status atual
   * - Data de compra
   * - URLs das imagens existentes
   * - URL da nota fiscal existente
   */
  void _populateFields() {
    final asset = widget.asset!;
    
    // Preenche o campo de título
    _tituloController.text = asset.titulo;
    
    // Define seleções dos dropdowns
    _selectedCategoryId = asset.categoriaId;
    _selectedLocationId = asset.localizacaoId;
    _selectedStatus = asset.status;
    
    // Define data de compra (se existir)
    _dataCompra = asset.dataCompra;
    
    // Copia lista de URLs das imagens existentes
    _existingImageUrls = List.from(asset.fotosUrls);
    
    // Define nota fiscal existente (se houver)
    _existingNotaFiscalUrl = asset.notaFiscalUrl;
  }

  /**
   * MÉTODO: _loadInitialData
   * 
   * Carrega dados iniciais necessários para a tela (categorias e localizações).
   * Executa requisições ao Firestore de forma assíncrona e paralela.
   * 
   * PROCESSO:
   * 1. Ativa indicador de loading
   * 2. Executa requisições em paralelo usando Future.wait
   * 3. Atualiza estado com os dados recebidos
   * 4. Desativa loading e trata erros se necessário
   * 
   * TRATAMENTO DE ERROS:
   * - Verifica se widget ainda está montado antes de atualizar estado
   * - Exibe SnackBar com mensagem de erro se requisição falhar
   */
  Future<void> _loadInitialData() async {
    // Ativa indicador de loading
    setState(() => _isLoading = true);
    
    try {
      // Prepara requisições em paralelo para melhor performance
      final categoriesFuture = _firestoreService.getCategories().first;
      final locationsFuture = _firestoreService.getLocations().first;
      
      // Executa ambas as requisições simultaneamente
      final results = await Future.wait([categoriesFuture, locationsFuture]);
      
      // Verifica se widget ainda está montado (prevenção de vazamento de memória)
      if (mounted) {
        setState(() {
          // Atualiza listas com os dados recebidos
          _categories = results[0] as List<Category>;
          _locations = results[1] as List<Location>;
          _isLoading = false;
        });
      }
    } catch (e) {
      // Tratamento de erro seguro
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar dados: $e')),
        );
      }
    }
  }

  /**
   * MÉTODO: _pickImages
   * 
   * Permite ao usuário selecionar múltiplas imagens da galeria.
   * Aplica otimizações para reduzir tamanho dos arquivos.
   * 
   * CONFIGURAÇÕES DE OTIMIZAÇÃO:
   * - Largura máxima: 1024px
   * - Altura máxima: 1024px  
   * - Qualidade: 85% (balanço entre qualidade e tamanho)
   * 
   * PROCESSO:
   * 1. Abre galeria para seleção múltipla
   * 2. Converte XFile para File
   * 3. Adiciona à lista de imagens selecionadas
   * 4. Atualiza interface com as novas imagens
   */
  Future<void> _pickImages() async {
    try {
      // Abre galeria para seleção múltipla com otimizações
      final List<XFile> pickedFiles = await _imagePicker.pickMultiImage(
        maxWidth: 1024,    // Reduz largura para economizar espaço
        maxHeight: 1024,   // Reduz altura para economizar espaço
        imageQuality: 85,  // Comprime imagem mantendo boa qualidade
      );
      
      // Se usuário selecionou pelo menos uma imagem
      if (pickedFiles.isNotEmpty) {
        setState(() {
          // Converte XFile para File e adiciona à lista
          _selectedImages.addAll(pickedFiles.map((xFile) => File(xFile.path)));
        });
      }
    } catch (e) {
      // Tratamento de erro com verificação de estado
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao selecionar imagens: $e')),
        );
      }
    }
  }

  /**
   * MÉTODO: _takePhoto
   * 
   * Permite ao usuário tirar uma foto usando a câmera do dispositivo.
   * Aplica as mesmas otimizações da seleção de galeria.
   * 
   * CONFIGURAÇÕES DE OTIMIZAÇÃO:
   * - Fonte: Câmera do dispositivo
   * - Largura máxima: 1024px
   * - Altura máxima: 1024px
   * - Qualidade: 85% (balanço entre qualidade e tamanho)
   * 
   * PROCESSO:
   * 1. Abre câmera para captura
   * 2. Se foto foi tirada, converte para File
   * 3. Adiciona à lista de imagens selecionadas
   * 4. Atualiza interface
   */
  Future<void> _takePhoto() async {
    try {
      // Abre câmera para captura com otimizações
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,  // Especifica uso da câmera
        maxWidth: 1024,    // Reduz largura para economizar espaço
        maxHeight: 1024,   // Reduz altura para economizar espaço
        imageQuality: 85,  // Comprime imagem mantendo boa qualidade
      );
      
      // Se usuário tirou a foto (não cancelou)
      if (photo != null) {
        setState(() {
          // Converte XFile para File e adiciona à lista
          _selectedImages.add(File(photo.path));
        });
      }
    } catch (e) {
      // Tratamento de erro com verificação de estado
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao tirar foto: $e')),
        );
      }
    }
  }

  /**
   * MÉTODO: _pickNotaFiscal
   * 
   * Permite ao usuário selecionar uma imagem da nota fiscal da galeria.
   * Aceita apenas uma imagem por vez (substitui a anterior se houver).
   * 
   * CONFIGURAÇÕES DE OTIMIZAÇÃO:
   * - Fonte: Galeria do dispositivo
   * - Largura máxima: 1024px
   * - Altura máxima: 1024px
   * - Qualidade: 85% (balanço entre qualidade e tamanho)
   * 
   * PROCESSO:
   * 1. Abre galeria para seleção única
   * 2. Se imagem foi selecionada, converte para File
   * 3. Substitui nota fiscal anterior (se houver)
   * 4. Atualiza interface
   */
  Future<void> _pickNotaFiscal() async {
    try {
      // Abre galeria para seleção única com otimizações
      final XFile? file = await _imagePicker.pickImage(
        source: ImageSource.gallery,  // Especifica uso da galeria
        maxWidth: 1024,    // Reduz largura para economizar espaço
        maxHeight: 1024,   // Reduz altura para economizar espaço
        imageQuality: 85,  // Comprime imagem mantendo boa qualidade
      );
      
      // Se usuário selecionou uma imagem
      if (file != null) {
        setState(() {
          // Substitui nota fiscal anterior (se houver)
          _notaFiscalFile = File(file.path);
        });
      }
    } catch (e) {
      // Tratamento de erro com verificação de estado
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao selecionar nota fiscal: $e')),
        );
      }
    }
  }

  /**
   * MÉTODO: _selectDate
   * 
   * Abre um seletor de data para o usuário escolher a data de compra do ativo.
   * Configurado para o formato brasileiro e com limites de data apropriados.
   * 
   * CONFIGURAÇÕES:
   * - Data inicial: Data atual de compra ou hoje se não definida
   * - Data mínima: 1º de janeiro de 2000
   * - Data máxima: Hoje (não permite datas futuras)
   * - Idioma: Português brasileiro
   * 
   * PROCESSO:
   * 1. Abre dialog de seleção de data
   * 2. Se usuário selecionou uma data, atualiza o estado
   * 3. Interface é atualizada automaticamente
   */
  Future<void> _selectDate() async {
    // Abre seletor de data com configurações em português
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dataCompra ?? DateTime.now(),  // Data atual ou hoje
      firstDate: DateTime(2000),       // Data mínima permitida
      lastDate: DateTime.now(),        // Data máxima (hoje)
      locale: const Locale('pt', 'BR'), // Configuração para português brasileiro
    );
    
    // Se usuário selecionou uma data (não cancelou)
    if (picked != null) {
      setState(() {
        _dataCompra = picked;
      });
    }
  }

  /**
   * MÉTODO: _removeNewImage
   * 
   * Remove uma imagem recém-selecionada da lista de imagens.
   * Usado para imagens que ainda não foram enviadas ao servidor.
   * 
   * PARÂMETROS:
   * - index: Índice da imagem na lista _selectedImages
   * 
   * PROCESSO:
   * - Remove da lista local de arquivos
   * - Interface é atualizada automaticamente
   */
  void _removeNewImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  /**
   * MÉTODO: _removeExistingImage
   * 
   * Remove uma imagem existente da lista de URLs.
   * Usado para imagens que já estão no Firebase Storage.
   * 
   * PARÂMETROS:
   * - url: URL da imagem a ser removida
   * 
   * PROCESSO:
   * - Remove da lista de URLs existentes
   * - Interface é atualizada automaticamente
   * - Imagem será removida do Firebase ao salvar o ativo
   */
  void _removeExistingImage(String url) {
    setState(() {
      _existingImageUrls.remove(url);
    });
  }

  /**
   * MÉTODO: _saveAsset
   * 
   * Método principal para salvar ou atualizar um ativo.
   * Realiza validação completa, upload de arquivos e operações no banco.
   * 
   * PROCESSO DE VALIDAÇÃO:
   * 1. Valida campos obrigatórios do formulário
   * 2. Verifica se categoria foi selecionada
   * 3. Verifica se localização foi selecionada
   * 
   * PROCESSO DE UPLOAD:
   * 1. Faz upload das novas imagens selecionadas
   * 2. Faz upload da nota fiscal (se houver nova)
   * 3. Combina URLs existentes com novas
   * 
   * PROCESSO DE SALVAMENTO:
   * 1. Cria objeto Asset com todos os dados
   * 2. Decide entre criar novo ou atualizar existente
   * 3. Salva no Firestore
   * 4. Retorna à tela anterior com resultado
   * 
   * TRATAMENTO DE ERROS:
   * - Exibe mensagens de validação
   * - Trata erros de upload e salvamento
   * - Mantém estado consistente em caso de falha
   */
  Future<void> _saveAsset() async {
    // === VALIDAÇÃO DE CAMPOS OBRIGATÓRIOS ===
    // Valida todos os campos do formulário
    if (!_formKey.currentState!.validate()) return;
    
    // Verifica se categoria foi selecionada
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma categoria')),
      );
      return;
    }
    
    // Verifica se localização foi selecionada
    if (_selectedLocationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um local')),
      );
      return;
    }

    // Ativa indicador de loading
    setState(() => _isLoading = true);

    try {
      // === UPLOAD DE NOVAS IMAGENS ===
      List<String> newImageUrls = [];
      if (_selectedImages.isNotEmpty) {
        // Faz upload de múltiplas imagens para pasta específica do ativo
        newImageUrls = await _storageService.uploadMultipleImages(
          _selectedImages,
          folder: 'assets/${widget.asset?.id ?? DateTime.now().millisecondsSinceEpoch}',
        );
      }

      // === UPLOAD DA NOTA FISCAL ===
      String? notaFiscalUrl = _existingNotaFiscalUrl;
      if (_notaFiscalFile != null) {
        // Faz upload da nova nota fiscal
        notaFiscalUrl = await _storageService.uploadImage(
          _notaFiscalFile!,
          folder: 'notas_fiscais',
        );
      }

      // === COMBINAÇÃO DE URLS DE IMAGENS ===
      // Combina imagens existentes com novas imagens
      List<String> allImageUrls = [..._existingImageUrls, ...newImageUrls];

      // === CRIAÇÃO DO OBJETO ASSET ===
      final asset = Asset(
        id: widget.asset?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        titulo: _tituloController.text.trim(),
        fotosUrls: allImageUrls,
        categoriaId: _selectedCategoryId!,
        localizacaoId: _selectedLocationId!,
        status: _selectedStatus,
        isAcessorio: widget.isAcessorio,
        dataCompra: _dataCompra,
        notaFiscalUrl: notaFiscalUrl,
        createdAt: widget.asset?.createdAt,  // Mantém data original se editando
        updatedAt: DateTime.now(),           // Sempre atualiza timestamp
      );

      // === SALVAMENTO NO FIRESTORE ===
      if (widget.asset == null) {
        // Modo criação: adiciona novo ativo
        await _firestoreService.addAsset(asset);
      } else {
        // Modo edição: atualiza ativo existente
        await _firestoreService.updateAsset(asset);
      }

      // === RETORNO À TELA ANTERIOR ===
      if (mounted) {
        // Retorna true para indicar que operação foi bem-sucedida
        Navigator.pop(context, true);
      }
    } catch (e) {
      // === TRATAMENTO DE ERROS ===
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e')),
        );
      }
    }
  }

  /**
   * MÉTODO: build
   * 
   * Constrói a interface da tela de adicionar/editar ativo.
   * Exibe diferentes layouts baseados no estado (loading, formulário).
   * 
   * ESTRUTURA DA INTERFACE:
   * 1. AppBar com título dinâmico
   * 2. Loading indicator ou formulário principal
   * 3. Seção de fotos com grid horizontal
   * 4. Campos de formulário organizados
   * 5. Seção de nota fiscal
   * 6. Botão de salvar
   * 
   * RESPONSIVIDADE:
   * - SingleChildScrollView para telas pequenas
   * - Cards para organizar seções
   * - Padding consistente
   */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // === BARRA SUPERIOR ===
      appBar: AppBar(
        // Título dinâmico baseado no modo (adicionar/editar) e tipo (ativo/acessório)
        title: Text(widget.asset == null 
            ? 'Adicionar ${widget.isAcessorio ? "Acessório" : "Ativo"}'
            : 'Editar ${widget.isAcessorio ? "Acessório" : "Ativo"}'),
      ),
      
      // === CORPO DA TELA ===
      body: _isLoading
          // Estado de loading: mostra indicador centralizado
          ? const Center(child: CircularProgressIndicator())
          // Estado normal: mostra formulário
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // === SEÇÃO DE FOTOS ===
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Título da seção
                            const Text(
                              'Fotos do Ativo',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Botões para adicionar fotos
                            Row(
                              children: [
                                // Botão para tirar foto com câmera
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _takePhoto,
                                    icon: const Icon(Icons.camera_alt),
                                    label: const Text('Tirar Foto'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Botão para selecionar da galeria
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _pickImages,
                                    icon: const Icon(Icons.photo_library),
                                    label: const Text('Galeria'),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // Grid horizontal de fotos (só aparece se há imagens)
                            if (_existingImageUrls.isNotEmpty || _selectedImages.isNotEmpty)
                              SizedBox(
                                height: 120,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: [
                                    // Imagens já existentes no Firebase Storage
                                    ..._existingImageUrls.map((url) => _buildImageItem(
                                      imageUrl: url,
                                      onRemove: () => _removeExistingImage(url),
                                    )),
                                    // Novas imagens selecionadas localmente
                                    ..._selectedImages.asMap().entries.map((entry) => 
                                      _buildImageItem(
                                        imageFile: entry.value,
                                        onRemove: () => _removeNewImage(entry.key),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // === CAMPOS DO FORMULÁRIO ===
                    // Campo de título/nome do ativo
                    CustomTextField(
                      controller: _tituloController,
                      hintText: 'Nome do Ativo',
                    ),
                    const SizedBox(height: 16),

                    // Dropdown de categoria
                    DropdownButtonFormField<String>(
                      value: _selectedCategoryId,
                      decoration: const InputDecoration(
                        labelText: 'Categoria',
                        border: OutlineInputBorder(),
                      ),
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category.id,
                          child: Text(category.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategoryId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Selecione uma categoria';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Campo de ID (somente leitura, apenas informativo)
                    TextFormField(
                      initialValue: widget.asset?.id ?? 'Será gerado automaticamente',
                      decoration: const InputDecoration(
                        labelText: 'ID do Ativo',
                        border: OutlineInputBorder(),
                        enabled: false,
                      ),
                      readOnly: true,
                    ),
                    const SizedBox(height: 16),

                    // Dropdown de localização
                    DropdownButtonFormField<String>(
                      value: _selectedLocationId,
                      decoration: const InputDecoration(
                        labelText: 'Local',
                        border: OutlineInputBorder(),
                      ),
                      items: _locations.map((location) {
                        return DropdownMenuItem(
                          value: location.id,
                          child: Text(location.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedLocationId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Selecione um local';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Seletor de data de compra
                    InkWell(
                      onTap: _selectDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Data de Compra',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          _dataCompra != null
                              ? '${_dataCompra!.day}/${_dataCompra!.month}/${_dataCompra!.year}'
                              : 'Selecione a data',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Dropdown de status do ativo
                    DropdownButtonFormField<AssetStatus>(
                      value: _selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                      ),
                      items: AssetStatus.values.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(_getStatusDisplayName(status)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedStatus = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // === SEÇÃO DE NOTA FISCAL ===
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Nota Fiscal',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Mostra nota fiscal anexada ou botão para anexar
                            if (_notaFiscalFile != null || _existingNotaFiscalUrl != null)
                              // Indicador de nota fiscal anexada
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.description),
                                    const SizedBox(width: 8),
                                    const Expanded(
                                      child: Text('Nota fiscal anexada'),
                                    ),
                                    // Botão para remover nota fiscal
                                    IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () {
                                        setState(() {
                                          _notaFiscalFile = null;
                                          _existingNotaFiscalUrl = null;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              )
                            else
                              // Botão para anexar nota fiscal
                              OutlinedButton.icon(
                                onPressed: _pickNotaFiscal,
                                icon: const Icon(Icons.attach_file),
                                label: const Text('Anexar Nota Fiscal'),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // === BOTÃO DE SALVAR ===
                    CustomElevatedButton(
                      text: widget.asset == null ? 'Adicionar' : 'Atualizar',
                      onPressed: _saveAsset,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  /**
   * WIDGET HELPER: _buildImageItem
   * 
   * Constrói um item de imagem para o grid horizontal de fotos.
   * Pode exibir imagem da URL (existente) ou arquivo local (nova).
   * 
   * PARÂMETROS:
   * - imageUrl: URL da imagem (para imagens existentes no Firebase)
   * - imageFile: Arquivo local (para imagens recém-selecionadas)
   * - onRemove: Callback para remover a imagem
   * 
   * CARACTERÍSTICAS:
   * - Tamanho fixo (100x100)
   * - Bordas arredondadas
   * - Botão de remoção no canto superior direito
   * - Tratamento de erro para imagens da web
   * - Ajuste de imagem (cover) para manter proporção
   */
  Widget _buildImageItem({
    String? imageUrl,
    File? imageFile,
    required VoidCallback onRemove,
  }) {
    return Container(
      width: 100,
      height: 100,
      margin: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          // Imagem com bordas arredondadas
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imageUrl != null
                // Imagem da web (existente no Firebase)
                ? Image.network(
                    imageUrl,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    // Mostra ícone de erro se falha ao carregar
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.error),
                      );
                    },
                  )
                // Imagem local (recém-selecionada)
                : Image.file(
                    imageFile!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
          ),
          // Botão de remoção no canto superior direito
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 16),
                onPressed: onRemove,
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /**
   * MÉTODO HELPER: _getStatusDisplayName
   * 
   * Converte o enum AssetStatus para nome em português para exibição.
   * 
   * PARÂMETROS:
   * - status: Enum AssetStatus a ser convertido
   * 
   * RETORNO:
   * - String: Nome do status em português
   */
  String _getStatusDisplayName(AssetStatus status) {
    switch (status) {
      case AssetStatus.disponivel:
        return 'Disponível';
      case AssetStatus.emprestado:
        return 'Emprestado';
      case AssetStatus.emUso:
        return 'Em Uso';
    }
  }

  /**
   * MÉTODO DO CICLO DE VIDA: dispose
   * 
   * Libera recursos quando o widget é removido da árvore.
   * Essencial para evitar vazamentos de memória.
   * 
   * RECURSOS LIBERADOS:
   * - TextEditingController do título
   * - Outros recursos do widget pai
   */
  @override
  void dispose() {
    _tituloController.dispose();
    super.dispose();
  }
}