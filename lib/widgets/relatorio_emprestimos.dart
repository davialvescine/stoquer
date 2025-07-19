// widgets/relatorio_emprestimos.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// Remova a linha abaixo se o arquivo não existir ou adicione o arquivo 'emprestimo.dart' no seu projeto.
// import '../models/emprestimo.dart';
// Remova a linha abaixo se o arquivo não existir ou adicione o arquivo 'emprestimo_service.dart' no seu projeto.
// import '../services/emprestimo_service.dart';

class RelatorioEmprestimosWidget extends StatefulWidget {
  const RelatorioEmprestimosWidget({Key? key}) : super(key: key);

  @override
  State<RelatorioEmprestimosWidget> createState() =>
      _RelatorioEmprestimosWidgetState();
}

class _RelatorioEmprestimosWidgetState
    extends State<RelatorioEmprestimosWidget> {
  // A linha abaixo causará um erro se EmprestimoService não estiver definido.
  // final EmprestimoService _emprestimoService = EmprestimoService();
  DateTimeRange? _periodoSelecionado;
  String _tipoRelatorio = 'todos';

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Relatório de Empréstimos',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _tipoRelatorio,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de Relatório',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'todos', child: Text('Todos')),
                      DropdownMenuItem(value: 'ativos', child: Text('Ativos')),
                      DropdownMenuItem(
                          value: 'devolvidos', child: Text('Devolvidos')),
                      DropdownMenuItem(
                          value: 'atrasados', child: Text('Atrasados')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _tipoRelatorio = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _selecionarPeriodo,
                  icon: const Icon(Icons.date_range),
                  label: Text(_periodoSelecionado != null
                      ? '${DateFormat('dd/MM').format(_periodoSelecionado!.start)} - ${DateFormat('dd/MM').format(_periodoSelecionado!.end)}'
                      : 'Período'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _gerarRelatorio,
              icon: const Icon(Icons.file_download),
              label: const Text('Gerar Relatório'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selecionarPeriodo() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _periodoSelecionado ??
          DateTimeRange(
            start: DateTime.now().subtract(const Duration(days: 30)),
            end: DateTime.now(),
          ),
    );

    if (picked != null) {
      setState(() {
        _periodoSelecionado = picked;
      });
    }
  }

  void _gerarRelatorio() {
    // Implementar geração de relatório
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidade de geração de relatório em desenvolvimento'),
      ),
    );
  }
}