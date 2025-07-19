import 'package:flutter/material.dart';
import 'package:stoquer/models/ativo.dart';

class AtivoDetalhesScreen extends StatelessWidget {
  final Ativo ativo;

  const AtivoDetalhesScreen({super.key, required this.ativo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(ativo.nome),
        actions: [
          // Exemplo de um botão de edição que levaria de volta ao formulário
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Lógica para navegar para a tela de formulário em modo de edição
              // Ex: Navigator.push(context, MaterialPageRoute(builder: (_) => AtivoFormScreen(ativo: ativo)));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildDetailRow('Código', ativo.codigo),
            _buildDetailRow('Categoria', ativo.categoria),
            _buildDetailRow('Descrição', ativo.descricao),
            _buildDetailRow('Disponível', ativo.disponivel ? 'Sim' : 'Não'),
            _buildDetailRow('Localização', ativo.localizacao ?? 'N/A'),
            _buildDetailRow('Condição', ativo.condicao ?? 'N/A'),
            _buildDetailRow('Número de Série', ativo.numeroSerie ?? 'N/A'),
            _buildDetailRow('Valor Estimado', 'R\$ ${ativo.valorEstimado?.toStringAsFixed(2) ?? '0.00'}'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}