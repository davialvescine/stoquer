/**
 * TELA DE DETALHES DO ATIVO
 * 
 * Exibe informações completas de um ativo específico com funcionalidades avançadas
 * de visualização, edição e impressão de etiquetas.
 * 
 * FUNCIONALIDADES PRINCIPAIS:
 * - Carousel de imagens com navegação e zoom
 * - Visualização full-screen de imagens
 * - Informações completas do ativo organizadas em cards
 * - Geração e exibição de QR Code
 * - Impressão de etiqueta PDF com QR Code
 * - Edição e exclusão do ativo
 * - Atualização automática após edição
 * - Status colorido e informações de sistema
 */

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:typed_data';
import '../../models/asset_model.dart';
import '../../models/category_model.dart';
import '../../models/location_model.dart';
import '../../services/firestore_service.dart';
import 'add_edit_asset_screen.dart';

/**
 * WIDGET PRINCIPAL: AssetDetailsScreen
 * 
 * StatefulWidget que exibe detalhes completos de um ativo específico.
 * Permite visualização, edição e impressão de informações do ativo.
 */
class AssetDetailsScreen extends StatefulWidget {
  // Ativo a ser exibido (obrigatório)
  final Asset asset;
  
  const AssetDetailsScreen({
    super.key,
    required this.asset,
  });

  @override
  State<AssetDetailsScreen> createState() => _AssetDetailsScreenState();
}

/**
 * ESTADO DA TELA: _AssetDetailsScreenState
 * 
 * Gerencia o estado da tela de detalhes do ativo.
 * Controla carousel de imagens, dados relacionados e operações CRUD.
 */
class _AssetDetailsScreenState extends State<AssetDetailsScreen> {
  // === SERVIÇOS ===
  // Serviço para operações no Firestore
  final FirestoreService _firestoreService = FirestoreService();
  
  // Controlador para navegação do carousel de imagens
  final PageController _pageController = PageController();
  
  // === ESTADO DA INTERFACE ===
  // Índice da imagem atual no carousel
  int _currentImageIndex = 0;
  
  // === DADOS RELACIONADOS ===
  // Categoria do ativo (carregada do Firestore)
  Category? _category;
  
  // Localização do ativo (carregada do Firestore)
  Location? _location;
  
  // Versão atualizada do ativo (sincronizada após edições)
  Asset? _updatedAsset;
  
  /**
   * MÉTODO DO CICLO DE VIDA: initState
   * 
   * Inicializa a tela carregando dados relacionados e definindo o ativo atual.
   * Executado uma vez quando o widget é criado.
   */
  @override
  void initState() {
    super.initState();
    _loadRelatedData();
    _updatedAsset = widget.asset;
  }

  /**
   * MÉTODO: _loadRelatedData
   * 
   * Carrega dados relacionados ao ativo (categoria e localização).
   * Busca informações no Firestore para exibir nomes ao invés de IDs.
   * 
   * PROCESSO:
   * 1. Carrega listas de categorias e localizações
   * 2. Busca a categoria específica pelo ID
   * 3. Busca a localização específica pelo ID
   * 4. Atualiza estado com os dados encontrados
   * 5. Fornece valores padrão se não encontrar
   * 
   * TRATAMENTO DE ERROS:
   * - Valores padrão para categoria e localização não encontradas
   * - Verificação de estado mounted para evitar vazamentos
   */
  Future<void> _loadRelatedData() async {
    try {
      // Carrega listas de categorias e localizações
      final categories = await _firestoreService.getCategories().first;
      final locations = await _firestoreService.getLocations().first;
      
      // Verifica se widget ainda está montado
      if (mounted) {
        setState(() {
          // Busca categoria específica pelo ID
          _category = categories.firstWhere(
            (cat) => cat.id == _updatedAsset!.categoriaId,
            orElse: () => Category(id: '', name: 'Sem categoria'),
          );
          
          // Busca localização específica pelo ID
          _location = locations.firstWhere(
            (loc) => loc.id == _updatedAsset!.localizacaoId,
            orElse: () => Location(id: '', name: 'Sem local'),
          );
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar dados relacionados: $e');
    }
  }

  /**
   * MÉTODO: _deleteAsset
   * 
   * Exibe dialog de confirmação e executa exclusão do ativo.
   * Após exclusão bem-sucedida, retorna à tela anterior.
   * 
   * PROCESSO:
   * 1. Exibe AlertDialog com confirmação
   * 2. Se confirmado, executa exclusão no Firestore
   * 3. Navega de volta para tela anterior
   * 4. Exibe feedback de sucesso ou erro
   * 
   * SEGURANÇA:
   * - Confirmação obrigatória com aviso sobre irreversibilidade
   * - Verificação de estado mounted antes de operações UI
   * - Tratamento de erros com mensagens informativas
   */
  Future<void> _deleteAsset() async {
    // Exibe dialog de confirmação
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Deseja realmente excluir "${_updatedAsset!.titulo}"?\n\nEsta ação não pode ser desfeita.'),
        actions: [
          // Botão Cancelar
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          // Botão Excluir (vermelho para indicar ação destrutiva)
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    
    // Se confirmou exclusão e widget ainda está montado
    if (confirm == true && mounted) {
      try {
        // Executa exclusão no Firestore
        await _firestoreService.deleteAsset(_updatedAsset!.id);
        
        if (mounted) {
          // Retorna para tela anterior
          Navigator.pop(context);
          
          // Exibe mensagem de sucesso
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ativo excluído com sucesso')),
          );
        }
      } catch (e) {
        // Exibe mensagem de erro
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao excluir: $e')),
          );
        }
      }
    }
  }

  /**
   * MÉTODO: _editAsset
   * 
   * Navega para tela de edição e atualiza dados após retorno.
   * Mantém a tela de detalhes sincronizada com alterações.
   * 
   * PROCESSO:
   * 1. Navega para tela de edição passando o ativo atual
   * 2. Aguarda resultado da edição
   * 3. Se houve alteração, recarrega dados do Firestore
   * 4. Atualiza estado com dados mais recentes
   * 5. Recarrega dados relacionados (categoria/localização)
   * 
   * SINCRONIZAÇÃO:
   * - Busca versão atualizada do ativo após edição
   * - Atualiza interface com dados mais recentes
   * - Recarrega dados relacionados para manter consistência
   */
  Future<void> _editAsset() async {
    // Navega para tela de edição
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditAssetScreen(
          asset: _updatedAsset,
          isAcessorio: _updatedAsset!.isAcessorio,
        ),
      ),
    );
    
    // Se houve alteração e widget ainda está montado
    if (result == true && mounted) {
      // Recarrega o ativo atualizado do Firestore
      try {
        final assets = await _firestoreService.getAssets().first;
        final updatedAsset = assets.firstWhere(
          (a) => a.id == _updatedAsset!.id,
          orElse: () => _updatedAsset!,
        );
        
        // Atualiza estado com dados mais recentes
        setState(() {
          _updatedAsset = updatedAsset;
        });
        
        // Recarrega dados relacionados (categoria/localização)
        _loadRelatedData();
      } catch (e) {
        debugPrint('Erro ao recarregar ativo: $e');
      }
    }
  }

  /**
   * MÉTODO: _printQrCode
   * 
   * Gera e exibe preview de impressão de etiqueta PDF com QR Code.
   * Cria documento PDF com informações do ativo e QR Code para identificação.
   * 
   * PROCESSO:
   * 1. Cria documento PDF vazio
   * 2. Gera QR Code com ID do ativo
   * 3. Converte QR Code para imagem
   * 4. Cria página PDF com layout centralizado
   * 5. Adiciona título, QR Code e informações do ativo
   * 6. Exibe preview de impressão
   * 
   * CONTEÚDO DA ETIQUETA:
   * - Título do ativo em destaque
   * - QR Code grande (200x200) com ID do ativo
   * - ID do ativo em texto
   * - Categoria e localização
   * - Status atual
   * 
   * TECNOLOGIAS:
   * - qr_flutter: Geração do QR Code
   * - pdf: Criação do documento PDF
   * - printing: Interface de impressão
   */
  Future<void> _printQrCode() async {
    final pdf = pw.Document();
    
    // === GERAÇÃO DO QR CODE ===
    final qrPainter = QrPainter(
      data: _updatedAsset!.id,       // Dados: ID do ativo
      version: QrVersions.auto,      // Versão automática baseada no conteúdo
      gapless: false,                // Sem gaps entre modules
    );
    
    // Converte QR Code para imagem (300x300 pixels)
    final qrImage = await qrPainter.toImageData(300);
    if (qrImage == null) return;
    
    // === CRIAÇÃO DA PÁGINA PDF ===
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                // Título do ativo
                pw.Text(
                  _updatedAsset!.titulo,
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                
                // QR Code
                pw.Image(
                  pw.MemoryImage(Uint8List.view(qrImage.buffer)),
                  width: 200,
                  height: 200,
                ),
                pw.SizedBox(height: 20),
                
                // Informações do ativo
                pw.Text('ID: ${_updatedAsset!.id}'),
                pw.SizedBox(height: 10),
                pw.Text('Categoria: ${_category?.name ?? ""}'),
                pw.SizedBox(height: 10),
                pw.Text('Local: ${_location?.name ?? ""}'),
                pw.SizedBox(height: 10),
                pw.Text('Status: ${_updatedAsset!.statusDisplayName}'),
              ],
            ),
          );
        },
      ),
    );
    
    // === EXIBIÇÃO DO PREVIEW DE IMPRESSÃO ===
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  /**
   * MÉTODO: _showFullScreenImage
   * 
   * Navega para visualizador de imagens em tela cheia.
   * Permite visualização detalhada com zoom e navegação entre imagens.
   * 
   * PARÂMETROS:
   * - initialIndex: Índice da imagem inicial a ser exibida
   * 
   * FUNCIONALIDADES:
   * - Visualização em tela cheia
   * - Zoom e pan (InteractiveViewer)
   * - Navegação entre imagens com swipe
   * - Fundo preto para melhor contraste
   */
  void _showFullScreenImage(int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _FullScreenImageViewer(
          images: _updatedAsset!.fotosUrls,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  /**
   * MÉTODO: build
   * 
   * Constrói a interface da tela de detalhes do ativo.
   * Exibe informações organizadas em seções com carousel de imagens.
   * 
   * ESTRUTURA DA INTERFACE:
   * 1. AppBar com título e ações (editar/excluir)
   * 2. Carousel de imagens com indicadores
   * 3. Informações do ativo em cards organizados
   * 4. QR Code com opção de impressão
   * 
   * CARACTERÍSTICAS:
   * - Scroll vertical para conteúdo extenso
   * - Carousel horizontal para múltiplas imagens
   * - Cards para organizar informações
   * - Estado vazio para ativos sem imagens
   */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // === BARRA SUPERIOR ===
      appBar: AppBar(
        title: Text(_updatedAsset!.titulo),
        actions: [
          // Botão para editar ativo
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editAsset,
          ),
          // Botão para excluir ativo
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteAsset,
          ),
        ],
      ),
      
      // === CORPO DA TELA ===
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === CAROUSEL DE IMAGENS ===
            if (_updatedAsset!.fotosUrls.isNotEmpty) ...[
              SizedBox(
                height: 300,
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      itemCount: _updatedAsset!.fotosUrls.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentImageIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => _showFullScreenImage(index),
                          child: Container(
                            color: Colors.grey[200],
                            child: Image.network(
                              _updatedAsset!.fotosUrls[index],
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    
                    // Indicador de páginas
                    if (_updatedAsset!.fotosUrls.length > 1)
                      Positioned(
                        bottom: 16,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _updatedAsset!.fotosUrls.length,
                            (index) => Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentImageIndex == index
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey[400],
                              ),
                            ),
                          ),
                        ),
                      ),
                    
                    // Contador de fotos
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_currentImageIndex + 1}/${_updatedAsset!.fotosUrls.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                height: 200,
                color: Colors.grey[200],
                child: Center(
                  child: Icon(
                    _updatedAsset!.isAcessorio ? Icons.extension : Icons.devices,
                    size: 64,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
            
            // Informações do Ativo
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(_updatedAsset!.status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _updatedAsset!.statusDisplayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Título e ID
                  Text(
                    _updatedAsset!.titulo,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ID: ${_updatedAsset!.id}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Informações Principais
                  _buildInfoCard(
                    title: 'Informações Gerais',
                    children: [
                      _buildInfoRow('Tipo', _updatedAsset!.isAcessorio ? 'Acessório' : 'Ativo'),
                      _buildInfoRow('Categoria', _category?.name ?? 'Carregando...'),
                      _buildInfoRow('Localização', _location?.name ?? 'Carregando...'),
                      if (_updatedAsset!.dataCompra != null)
                        _buildInfoRow(
                          'Data de Compra',
                          '${_updatedAsset!.dataCompra!.day}/${_updatedAsset!.dataCompra!.month}/${_updatedAsset!.dataCompra!.year}',
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Datas do Sistema
                  _buildInfoCard(
                    title: 'Registro do Sistema',
                    children: [
                      _buildInfoRow(
                        'Criado em',
                        _formatDateTime(_updatedAsset!.createdAt),
                      ),
                      _buildInfoRow(
                        'Última atualização',
                        _formatDateTime(_updatedAsset!.updatedAt),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Nota Fiscal
                  if (_updatedAsset!.notaFiscalUrl != null) ...[
                    _buildInfoCard(
                      title: 'Nota Fiscal',
                      children: [
                        InkWell(
                          onTap: () => _showFullScreenImage(0),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.description, color: Colors.blue),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text('Visualizar Nota Fiscal'),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // QR Code
                  _buildInfoCard(
                    title: 'QR Code',
                    children: [
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: QrImageView(
                            data: _updatedAsset!.id,
                            version: QrVersions.auto,
                            size: 200,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: _printQrCode,
                          icon: const Icon(Icons.print),
                          label: const Text('Imprimir Etiqueta'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /**
   * WIDGET HELPER: _buildInfoCard
   * 
   * Constrói um card com título e lista de widgets filhos.
   * Usado para organizar informações em seções visuais.
   * 
   * PARÂMETROS:
   * - title: Título da seção
   * - children: Lista de widgets a serem exibidos no card
   * 
   * CARACTERÍSTICAS:
   * - Padding consistente
   * - Título em destaque
   * - Layout vertical para os filhos
   */
  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  /**
   * WIDGET HELPER: _buildInfoRow
   * 
   * Constrói uma linha de informação com label e valor.
   * Usado para exibir pares chave-valor de forma consistente.
   * 
   * PARÂMETROS:
   * - label: Rótulo da informação (ex: "Categoria")
   * - value: Valor da informação (ex: "Eletrônicos")
   * 
   * LAYOUT:
   * - Label com largura fixa (120px)
   * - Valor expandido ocupando espaço restante
   * - Estilos diferentes para label e valor
   */
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  /**
   * MÉTODO HELPER: _formatDateTime
   * 
   * Formata DateTime para exibição em formato brasileiro.
   * Inclui data e hora com zero à esquerda.
   * 
   * FORMATO: DD/MM/YYYY às HH:MM
   * EXEMPLO: 15/07/2024 às 14:30
   */
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/'
        '${dateTime.month.toString().padLeft(2, '0')}/'
        '${dateTime.year} às '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /**
   * MÉTODO HELPER: _getStatusColor
   * 
   * Retorna a cor apropriada para cada status do ativo.
   * Usado para colorir badges de status.
   * 
   * CORES:
   * - Disponível: Verde
   * - Emprestado: Laranja
   * - Em Uso: Azul
   */
  Color _getStatusColor(AssetStatus status) {
    switch (status) {
      case AssetStatus.disponivel:
        return Colors.green;
      case AssetStatus.emprestado:
        return Colors.orange;
      case AssetStatus.emUso:
        return Colors.blue;
    }
  }

  /**
   * MÉTODO DO CICLO DE VIDA: dispose
   * 
   * Libera recursos quando o widget é removido.
   * Evita vazamentos de memória.
   */
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

/**
 * WIDGET: _FullScreenImageViewer
 * 
 * Visualizador de imagens em tela cheia com funcionalidades avançadas.
 * Permite visualização detalhada com zoom, pan e navegação entre imagens.
 * 
 * FUNCIONALIDADES:
 * - Visualização em tela cheia com fundo preto
 * - Zoom e pan interativo (0.5x a 4.0x)
 * - Navegação entre imagens com swipe
 * - Página inicial configurável
 * - Tratamento de erro para imagens não carregadas
 * - AppBar transparente para controles mínimos
 */
class _FullScreenImageViewer extends StatelessWidget {
  // Lista de URLs das imagens a serem exibidas
  final List<String> images;
  
  // Índice da imagem inicial a ser exibida
  final int initialIndex;
  
  const _FullScreenImageViewer({
    required this.images,
    required this.initialIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fundo preto para melhor contraste
      backgroundColor: Colors.black,
      
      // AppBar transparente com botão de voltar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      
      // === BODY: CAROUSEL DE IMAGENS ===
      body: PageView.builder(
        // Inicia na página especificada
        controller: PageController(initialPage: initialIndex),
        itemCount: images.length,
        itemBuilder: (context, index) {
          return InteractiveViewer(
            // Configurações de zoom
            minScale: 0.5,  // Zoom mínimo (50%)
            maxScale: 4.0,  // Zoom máximo (400%)
            child: Center(
              child: Image.network(
                images[index],
                fit: BoxFit.contain,
                // Tratamento de erro para imagens não carregadas
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(
                    Icons.broken_image,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}