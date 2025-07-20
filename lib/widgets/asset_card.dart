import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/asset.dart';

class AssetCard extends StatelessWidget {
  final Asset asset;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const AssetCard({
    super.key,
    required this.asset,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header do card
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      // SOLUÇÃO: Corrigido de .withOpacity(0.1) para .withAlpha(26)
                      color: _getCategoryColor(asset.category).withAlpha(26),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(_getCategoryIcon(asset.category), color: _getCategoryColor(asset.category), size: 24),
                  ),
                  const SizedBox(width: 12),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(asset.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text(asset.category, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                  
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      // SOLUÇÃO: Corrigido de .withOpacity(0.1) para .withAlpha(26)
                      color: _getStatusColor(asset.status).withAlpha(26),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(asset.status),
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: _getStatusColor(asset.status)),
                    ),
                  ),
                  
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit': onEdit?.call(); break;
                        case 'delete': onDelete?.call(); break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 16), SizedBox(width: 8), Text('Editar')])),
                      const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 16, color: Colors.red), SizedBox(width: 8), Text('Excluir', style: TextStyle(color: Colors.red))])),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              if (asset.description.isNotEmpty)
                Text(asset.description, style: TextStyle(fontSize: 14, color: Colors.grey[700]), maxLines: 2, overflow: TextOverflow.ellipsis),
              
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(child: Text(asset.location, style: TextStyle(fontSize: 12, color: Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                  ),
                  Text(currencyFormat.format(asset.value), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green)),
                ],
              ),
              
              const SizedBox(height: 8),
              
              Row(
                children: [
                  Row(
                    children: [
                      Icon(Icons.qr_code, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(asset.qrCode, style: TextStyle(fontSize: 12, color: Colors.grey[600], fontFamily: 'monospace')),
                    ],
                  ),
                  const Spacer(),
                  Text(DateFormat('dd/MM/yyyy').format(asset.updatedAt), style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                ],
              ),
            ],
          ),
        ),
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active': case 'ativo': return Colors.green;
      case 'inactive': case 'inativo': return Colors.red;
      case 'maintenance': case 'manutenção': return Colors.orange;
      default: return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'active': return 'Ativo';
      case 'inactive': return 'Inativo';
      case 'maintenance': return 'Manutenção';
      default: return status;
    }
  }
}