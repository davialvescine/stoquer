/**
 * TELA DE LISTA DE ATIVOS
 * 
 * Exibe uma lista de ativos ou acessórios com funcionalidades avançadas
 * de busca, filtros, navegação e operações CRUD.
 * 
 * FUNCIONALIDADES PRINCIPAIS:
 * - Listagem dinâmica com StreamBuilder
 * - Busca por nome em tempo real
 * - Filtros por status, categoria e localização
 * - Swipe-to-delete com confirmação
 * - Navegação para detalhes e edição
 * - Estados vazios com call-to-action
 * - Interface adaptada para ativos e acessórios
 */

import 'package:flutter/material.dart';
import '../../models/asset_model.dart';
import '../../models/category_model.dart';
import '../../models/location_model.dart';
import '../../services/firestore_service.dart';
import 'add_edit_asset_screen.dart';
import 'asset_details_screen.dart';

/**
 * WIDGET PRINCIPAL: AssetListScreen
 * 
 * StatefulWidget que gerencia a listagem de ativos ou acessórios.
 * Suporta operações de busca, filtros e navegação.
 */
class AssetListScreen extends StatefulWidget {
  // Define se está mostrando acessórios (true) ou ativos (false)
  final bool isAcessorio;
  
  const AssetListScreen({super.key, required this.isAcessorio});

  @override
  State<AssetListScreen> createState() => _AssetListScreenState();
}

/**
 * ESTADO DA TELA: _AssetListScreenState
 * 
 * Gerencia todo o estado da tela de listagem de ativos.
 * Controla busca, filtros, dados e interações do usuário.
 */
class _AssetListScreenState extends State<AssetListScreen> {
  // === SERVIÇOS ===
  // Serviço para operações no Firestore
  final FirestoreService _firestoreService = FirestoreService();
  
  // Controlador para o campo de busca
  final TextEditingController _searchController = TextEditingController();
  
  // === ESTADO DE BUSCA E FILTROS ===
  // Query de busca atual (digitada pelo usuário)
  String _searchQuery = '';
  
  // Filtro por status selecionado (null = todos)
  AssetStatus? _filterStatus;
  
  // Filtro por categoria selecionada (null = todas)
  String? _filterCategoryId;
  
  // Filtro por localização selecionada (null = todas)
  String? _filterLocationId;
  
  // === DADOS PARA FILTROS ===
  // Lista de categorias disponíveis para filtro
  List<Category> _categories = [];
  
  // Lista de localizações disponíveis para filtro
  List<Location> _locations = [];

  /**
   * MÉTODO DO CICLO DE VIDA: initState
   * 
   * Inicializa a tela carregando dados necessários para os filtros.
   * Executado uma vez quando o widget é criado.
   */
  @override
  void initState() {
    super.initState();
    _loadFiltersData();
  }

  /**
   * MÉTODO: _loadFiltersData
   * 
   * Carrega categorias e localizações para popular os filtros.
   * Executa requisições em paralelo para melhor performance.
   * 
   * PROCESSO:
   * 1. Faz requisições paralelas para categorias e localizações
   * 2. Aguarda ambas completarem usando Future.wait
   * 3. Atualiza estado com os dados recebidos
   * 4. Trata erros sem interromper a aplicação
   */
  Future<void> _loadFiltersData() async {
    try {
      // Prepara requisições em paralelo
      final categoriesFuture = _firestoreService.getCategories().first;
      final locationsFuture = _firestoreService.getLocations().first;
      
      // Executa ambas simultaneamente
      final results = await Future.wait([categoriesFuture, locationsFuture]);
      
      // Verifica se widget ainda está montado (prevenção de vazamento)
      if (mounted) {
        setState(() {
          _categories = results[0] as List<Category>;
          _locations = results[1] as List<Location>;
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar filtros: $e');
    }
  }

  /**
   * MÉTODO: _filterAssets
   * 
   * Aplica todos os filtros ativos na lista de ativos.
   * Combina filtros de tipo, busca, status, categoria e localização.
   * 
   * PARÂMETROS:
   * - assets: Lista completa de ativos do Firestore
   * 
   * RETORNO:
   * - List<Asset>: Lista filtrada conforme critérios selecionados
   * 
   * FILTROS APLICADOS:
   * 1. Tipo: mostra apenas ativos ou acessórios
   * 2. Busca: nome contém o texto digitado
   * 3. Status: corresponde ao status selecionado
   * 4. Categoria: corresponde à categoria selecionada
   * 5. Localização: corresponde à localização selecionada
   */
  List<Asset> _filterAssets(List<Asset> assets) {
    return assets.where((asset) {
      // 1. Filtro por tipo (ativo/acessório) - sempre aplicado
      if (asset.isAcessorio != widget.isAcessorio) return false;
      
      // 2. Filtro por busca textual (case-insensitive)
      if (_searchQuery.isNotEmpty) {
        if (!asset.titulo.toLowerCase().contains(_searchQuery.toLowerCase())) {
          return false;
        }
      }
      
      // 3. Filtro por status (se selecionado)
      if (_filterStatus != null && asset.status != _filterStatus) {
        return false;
      }
      
      // 4. Filtro por categoria (se selecionada)
      if (_filterCategoryId != null && asset.categoriaId != _filterCategoryId) {
        return false;
      }
      
      // 5. Filtro por localização (se selecionada)
      if (_filterLocationId != null && asset.localizacaoId != _filterLocationId) {
        return false;
      }
      
      // Se passou por todos os filtros, inclui o ativo
      return true;
    }).toList();
  }

  /**
   * MÉTODO: _showFilterDialog
   * 
   * Exibe um modal bottom sheet com opções de filtro avançado.
   * Permite filtrar por status, categoria e localização.
   * 
   * CARACTERÍSTICAS:
   * - Modal com bordas arredondadas no topo
   * - StatefulBuilder para estado independente do modal
   * - Chips para seleção de status
   * - Dropdowns para categoria e localização
   * - Botão para limpar todos os filtros
   * - Atualizações em tempo real na tela principal
   */
  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        // StatefulBuilder permite estado independente dentro do modal
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título do modal
              const Text(
                'Filtros',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              
              // === FILTRO POR STATUS ===
              const Text('Status:', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  // Chip "Todos" para limpar filtro de status
                  FilterChip(
                    label: const Text('Todos'),
                    selected: _filterStatus == null,
                    onSelected: (selected) {
                      setModalState(() => _filterStatus = null);
                      setState(() {}); // Atualiza tela principal
                    },
                  ),
                  // Chips para cada status disponível
                  ...AssetStatus.values.map((status) => FilterChip(
                    label: Text(_getStatusDisplayName(status)),
                    selected: _filterStatus == status,
                    onSelected: (selected) {
                      setModalState(() => _filterStatus = selected ? status : null);
                      setState(() {}); // Atualiza tela principal
                    },
                  )),
                ],
              ),
              const SizedBox(height: 16),
              
              // === FILTRO POR CATEGORIA ===
              const Text('Categoria:', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButton<String?>(
                value: _filterCategoryId,
                isExpanded: true,
                hint: const Text('Todas as categorias'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Todas')),
                  ..._categories.map((cat) => DropdownMenuItem(
                    value: cat.id,
                    child: Text(cat.name),
                  )),
                ],
                onChanged: (value) {
                  setModalState(() => _filterCategoryId = value);
                  setState(() {}); // Atualiza tela principal
                },
              ),
              const SizedBox(height: 16),
              
              // === FILTRO POR LOCAL ===
              const Text('Local:', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButton<String?>(
                value: _filterLocationId,
                isExpanded: true,
                hint: const Text('Todos os locais'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Todos')),
                  ..._locations.map((loc) => DropdownMenuItem(
                    value: loc.id,
                    child: Text(loc.name),
                  )),
                ],
                onChanged: (value) {
                  setModalState(() => _filterLocationId = value);
                  setState(() {}); // Atualiza tela principal
                },
              ),
              const SizedBox(height: 20),
              
              // === BOTÃO LIMPAR FILTROS ===
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    // Limpa todos os filtros
                    setModalState(() {
                      _filterStatus = null;
                      _filterCategoryId = null;
                      _filterLocationId = null;
                    });
                    setState(() {}); // Atualiza tela principal
                    Navigator.pop(context); // Fecha modal
                  },
                  child: const Text('Limpar Filtros'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /**
   * MÉTODO: _deleteAsset
   * 
   * Exibe dialog de confirmação e executa exclusão do ativo.
   * Implementa padrão seguro para operações destrutivas.
   * 
   * PARÂMETROS:
   * - asset: Ativo a ser excluído
   * 
   * PROCESSO:
   * 1. Exibe AlertDialog para confirmação
   * 2. Se confirmado, executa exclusão no Firestore
   * 3. Exibe feedback de sucesso ou erro
   * 4. Lista é atualizada automaticamente via StreamBuilder
   * 
   * SEGURANÇA:
   * - Confirmação obrigatória antes da exclusão
   * - Verificação de estado 'mounted' antes de atualizações
   * - Tratamento de erros com mensagens informativas
   */
  Future<void> _deleteAsset(Asset asset) async {
    // Exibe dialog de confirmação
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Deseja realmente excluir "${asset.titulo}"?'),
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
        await _firestoreService.deleteAsset(asset.id);
        
        // Exibe mensagem de sucesso
        if (mounted) {
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
   * MÉTODO: build
   * 
   * Constrói a interface da tela de lista de ativos.
   * Implementa busca em tempo real, filtros e lista dinâmica.
   * 
   * ESTRUTURA DA INTERFACE:
   * 1. AppBar com título dinâmico e botão de filtros
   * 2. Barra de busca com campo de texto
   * 3. Lista principal com StreamBuilder
   * 4. Estados vazios informativos
   * 5. FloatingActionButton para adicionar novos
   * 
   * CARACTERÍSTICAS:
   * - Dados em tempo real via Stream
   * - Filtros aplicados automaticamente
   * - Swipe-to-delete nos items
   * - Navegação para detalhes e edição
   */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // === BARRA SUPERIOR ===
      appBar: AppBar(
        // Título dinâmico baseado no tipo (ativos/acessórios)
        title: Text(widget.isAcessorio ? 'Acessórios' : 'Ativos'),
        actions: [
          // Botão para abrir filtros avançados
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      
      // === CORPO DA TELA ===
      body: Column(
        children: [
          // === BARRA DE BUSCA ===
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar ${widget.isAcessorio ? "acessórios" : "ativos"}...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              // Busca em tempo real conforme usuário digita
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          
          // === LISTA PRINCIPAL ===
          Expanded(
            child: StreamBuilder<List<Asset>>(
              // Stream em tempo real do Firestore
              stream: _firestoreService.getAssets(),
              builder: (context, snapshot) {
                // Estado de loading
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                // === ESTADO VAZIO (sem dados) ===
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Ícone informativo baseado no tipo
                        Icon(
                          widget.isAcessorio ? Icons.extension_off : Icons.devices_other,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhum ${widget.isAcessorio ? "acessório" : "ativo"} encontrado',
                          style: const TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        // Call-to-action para adicionar o primeiro item
                        TextButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddEditAssetScreen(
                                isAcessorio: widget.isAcessorio,
                              ),
                            ),
                          ).then((_) => setState(() {})),
                          icon: const Icon(Icons.add),
                          label: const Text('Adicionar primeiro'),
                        ),
                      ],
                    ),
                  );
                }
                
                // === APLICAÇÃO DE FILTROS ===
                final filteredAssets = _filterAssets(snapshot.data!);
                
                // Estado vazio após filtros
                if (filteredAssets.isEmpty) {
                  return const Center(
                    child: Text(
                      'Nenhum resultado encontrado',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  );
                }
                
                // === LISTA DE ATIVOS ===
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredAssets.length,
                  itemBuilder: (context, index) {
                    final asset = filteredAssets[index];
                    
                    // Busca dados relacionados (categoria e localização)
                    final category = _categories.firstWhere(
                      (cat) => cat.id == asset.categoriaId,
                      orElse: () => Category(id: '', name: 'Sem categoria'),
                    );
                    final location = _locations.firstWhere(
                      (loc) => loc.id == asset.localizacaoId,
                      orElse: () => Location(id: '', name: 'Sem local'),
                    );
                    
                    // Item com funcionalidade swipe-to-delete
                    return Dismissible(
                      key: Key(asset.id),
                      direction: DismissDirection.endToStart, // Swipe da direita para esquerda
                      // Fundo vermelho com ícone de lixeira
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      // Intercepta dismiss para mostrar confirmação
                      confirmDismiss: (_) async {
                        await _deleteAsset(asset);
                        return false; // Não remove automaticamente
                      },
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AssetDetailsScreen(asset: asset),
                            ),
                          ).then((_) => setState(() {})),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                // Imagem do Ativo
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: asset.fotoPrincipal != null
                                        ? Image.network(
                                            asset.fotoPrincipal!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Icon(
                                              widget.isAcessorio 
                                                  ? Icons.extension 
                                                  : Icons.devices,
                                              size: 40,
                                              color: Colors.grey,
                                            ),
                                          )
                                        : Icon(
                                            widget.isAcessorio 
                                                ? Icons.extension 
                                                : Icons.devices,
                                            size: 40,
                                            color: Colors.grey,
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                
                                // Informações do Ativo
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        asset.titulo,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${category.name} • ${location.name}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(asset.status),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              asset.statusDisplayName,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          if (asset.dataCompra != null) ...[
                                            const SizedBox(width: 8),
                                            Icon(
                                              Icons.calendar_today,
                                              size: 16,
                                              color: Colors.grey[600],
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${asset.dataCompra!.day}/${asset.dataCompra!.month}/${asset.dataCompra!.year}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Ícone de navegação
                                Icon(
                                  Icons.chevron_right,
                                  color: Colors.grey[400],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      // === FLOATING ACTION BUTTON ===
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddEditAssetScreen(
              isAcessorio: widget.isAcessorio,
            ),
          ),
        ).then((_) => setState(() {})), // Atualiza lista ao voltar
        child: const Icon(Icons.add),
      ),
    );
  }

  /**
   * MÉTODO HELPER: _getStatusColor
   * 
   * Retorna a cor apropriada para cada status do ativo.
   * Usado para colorir os badges de status na lista.
   * 
   * CORES:
   * - Disponível: Verde (disponível para uso)
   * - Emprestado: Laranja (temporariamente fora)
   * - Em Uso: Azul (sendo usado atualmente)
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
   * MÉTODO HELPER: _getStatusDisplayName
   * 
   * Converte o enum AssetStatus para nome em português.
   * Usado em filtros e exibições na interface.
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
   * Libera recursos quando o widget é removido.
   * Previne vazamentos de memória.
   */
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}