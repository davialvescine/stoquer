import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/asset_provider.dart';
import '../models/asset.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AssetProvider>().loadAssets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AssetProvider>(
      builder: (context, assetProvider, child) {
        if (assetProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final assets = assetProvider.assets;
        
        return RefreshIndicator(
          onRefresh: () => assetProvider.loadAssets(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCards(assets),
                const SizedBox(height: 24),
                _buildCategoryChart(assets),
                const SizedBox(height: 24),
                _buildRecentAssets(assets),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryCards(List<Asset> assets) {
    final totalAssets = assets.length;
    final totalValue = assets.fold<double>(0, (sum, asset) => sum + asset.value);
    final activeAssets = assets.where((a) => a.status.toLowerCase() == 'active').length;
    final maintenanceAssets = assets.where((a) => a.status.toLowerCase() == 'maintenance').length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resumo Geral',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.5,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildSummaryCard('Total de Ativos', totalAssets.toString(), Icons.inventory, Colors.blue),
            _buildSummaryCard('Valor Total', 'R\$ ${totalValue.toStringAsFixed(0)}', Icons.attach_money, Colors.green),
            _buildSummaryCard('Ativos Ativos', activeAssets.toString(), Icons.check_circle, Colors.orange),
            _buildSummaryCard('Em Manutenção', maintenanceAssets.toString(), Icons.build, Colors.red),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // SOLUÇÃO: Troca de .withOpacity(0.1) para .withAlpha(26)
        color: color.withAlpha(26), 
        borderRadius: BorderRadius.circular(12),
        // SOLUÇÃO: Troca de .withOpacity(0.3) para .withAlpha(77)
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const Spacer(),
              Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildCategoryChart(List<Asset> assets) {
    if (assets.isEmpty) return const SizedBox();

    final Map<String, int> categoryCount = {};
    for (final asset in assets) {
      categoryCount[asset.category] = (categoryCount[asset.category] ?? 0) + 1;
    }

    final List<PieChartSectionData> sections = categoryCount.entries
        .map((entry) => PieChartSectionData(
              color: _getCategoryColor(entry.key),
              value: entry.value.toDouble(),
              title: '${entry.value}',
              radius: 100,
              titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ))
        .toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        // SOLUÇÃO: Troca de .withOpacity(0.1) para .withAlpha(26)
        boxShadow: [BoxShadow(color: Colors.grey.withAlpha(26), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ativos por Categoria', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SizedBox(height: 200, child: PieChart(PieChartData(sections: sections, centerSpaceRadius: 40, sectionsSpace: 2))),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: categoryCount.entries
                .map((entry) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 12, height: 12, color: _getCategoryColor(entry.key)),
                        const SizedBox(width: 4),
                        Text('${entry.key} (${entry.value})', style: const TextStyle(fontSize: 12)),
                      ],
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentAssets(List<Asset> assets) {
    if (assets.isEmpty) return const SizedBox();

    final recentAssets = List<Asset>.from(assets)..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        // SOLUÇÃO: Troca de .withOpacity(0.1) para .withAlpha(26)
        boxShadow: [BoxShadow(color: Colors.grey.withAlpha(26), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('Ativos Recentes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Spacer(),
            ],
          ),
          const SizedBox(height: 16),
          ...recentAssets.take(5).map((asset) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        // SOLUÇÃO: Troca de .withOpacity(0.1) para .withAlpha(26)
                        color: _getCategoryColor(asset.category).withAlpha(26),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(_getCategoryIcon(asset.category), color: _getCategoryColor(asset.category), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(asset.name, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text(asset.category, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        ],
                      ),
                    ),
                    Text('R\$ ${asset.value.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 12)),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'equipamentos': return Colors.blue;
      case 'móveis': return Colors.brown;
      case 'veículos': return Colors.orange;
      case 'tecnologia': return Colors.purple;
      default: return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'equipamentos': return Icons.build;
      case 'móveis': return Icons.chair;
      case 'veículos': return Icons.directions_car;
      case 'tecnologia': return Icons.computer;
      default: return Icons.inventory;
    }
  }
}