import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/asset_provider.dart';
import '../models/asset.dart';
import '../widgets/asset_card.dart';

class AssetsScreen extends StatefulWidget {
  const AssetsScreen({super.key});

  @override
  State<AssetsScreen> createState() => _AssetsScreenState();
}

class _AssetsScreenState extends State<AssetsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Todos';
  
  final List<String> _categories = ['Todos', 'Equipamentos', 'Móveis', 'Veículos', 'Tecnologia', 'Outros'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AssetProvider>().loadAssets();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestão de Ativos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddAssetDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de pesquisa
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Pesquisar ativos...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchController.clear(); setState(() {}); })
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
          
          // Filtro por categoria
          Container(
            height: 50,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) => setState(() { _selectedCategory = category; }),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Lista de ativos
          Expanded(
            child: Consumer<AssetProvider>(
              builder: (context, assetProvider, child) {
                if (assetProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (assetProvider.error.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                        const SizedBox(height: 16),
                        Text(assetProvider.error, style: TextStyle(color: Colors.red[300], fontSize: 16), textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(onPressed: () => assetProvider.loadAssets(), child: const Text('Tentar Novamente')),
                      ],
                    ),
                  );
                }
                
                List<Asset> filteredAssets = assetProvider.assets;
                
                if (_selectedCategory != 'Todos') {
                  filteredAssets = assetProvider.filterByCategory(_selectedCategory);
                }
                
                if (_searchController.text.isNotEmpty) {
                  filteredAssets = assetProvider.searchAssets(_searchController.text);
                }
                
                if (filteredAssets.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text('Nenhum ativo encontrado', style: TextStyle(color: Colors.grey[600], fontSize: 18)),
                        const SizedBox(height: 8),
                        Text('Adicione novos ativos ou ajuste os filtros', style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                      ],
                    ),
                  );
                }
                
                return RefreshIndicator(
                  onRefresh: () => assetProvider.loadAssets(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredAssets.length,
                    itemBuilder: (context, index) {
                      return AssetCard(
                        asset: filteredAssets[index],
                        onTap: () => _showAssetDetails(filteredAssets[index]),
                        onEdit: () => _showEditAssetDialog(filteredAssets[index]),
                        onDelete: () => _confirmDeleteAsset(filteredAssets[index]),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddAssetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Ativo'),
        content: const Text('Funcionalidade em desenvolvimento'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }

  void _showAssetDetails(Asset asset) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(asset.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Descrição: ${asset.description}'),
            Text('Categoria: ${asset.category}'),
            Text('Localização: ${asset.location}'),
            Text('QR Code: ${asset.qrCode}'),
            Text('Valor: R\$ ${asset.value.toStringAsFixed(2)}'),
            Text('Status: ${asset.status}'),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar'))],
      ),
    );
  }

  void _showEditAssetDialog(Asset asset) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Ativo'),
        content: const Text('Funcionalidade em desenvolvimento'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Salvar')),
        ],
      ),
    );
  }

  void _confirmDeleteAsset(Asset asset) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Deseja realmente excluir o ativo "${asset.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(context);
              context.read<AssetProvider>().deleteAsset(asset.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Ativo "${asset.name}" excluído'), backgroundColor: Colors.green),
              );
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}