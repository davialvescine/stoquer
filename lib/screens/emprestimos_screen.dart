// screens/emprestimos_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/emprestimo.dart';
import '../services/emprestimo_service.dart';
import '../widgets/emprestimo_form_dialog.dart';
import '../widgets/devolucao_dialog.dart';

class EmprestimosScreen extends StatefulWidget {
  const EmprestimosScreen({Key? key}) : super(key: key);

  @override
  State<EmprestimosScreen> createState() => _EmprestimosScreenState();
}

class _EmprestimosScreenState extends State<EmprestimosScreen> with SingleTickerProviderStateMixin {
  final EmprestimoService _emprestimoService = EmprestimoService();
  late TabController _tabController;
  String _filtroStatus = 'todos';
  String _termoBusca = '';
  final TextEditingController _buscaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _verificarEmprestimosAtrasados();
  }

  void _verificarEmprestimosAtrasados() async {
    await _emprestimoService.verificarEmprestimosAtrasados();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _buscaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestão de Empréstimos'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Todos', icon: Icon(Icons.list)),
            Tab(text: 'Ativos', icon: Icon(Icons.access_time)),
            Tab(text: 'Devolvidos', icon: Icon(Icons.check_circle)),
            Tab(text: 'Atrasados', icon: Icon(Icons.warning)),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildStatistics(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildEmprestimosList('todos'),
                _buildEmprestimosList('ativo'),
                _buildEmprestimosList('devolvido'),
                _buildEmprestimosList('atrasado'),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirDialogNovoEmprestimo,
        icon: const Icon(Icons.add),
        label: const Text('Novo Empréstimo'),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _buscaController,
        decoration: InputDecoration(
          hintText: 'Buscar por solicitante, ativo ou responsável...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _termoBusca.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _buscaController.clear();
                      _termoBusca = '';
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onChanged: (value) {
          setState(() {
            _termoBusca = value.toLowerCase();
          });
        },
      ),
    );
  }

  Widget _buildStatistics() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _emprestimoService.obterEstatisticas(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final stats = snapshot.data!;
        return Container(
          height: 100,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard('Total', stats['total'], Colors.blue),
              _buildStatCard('Ativos', stats['ativos'], Colors.green),
              _buildStatCard('Devolvidos', stats['devolvidos'], Colors.grey),
              _buildStatCard('Atrasados', stats['atrasados'], Colors.red),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String label, int value, Color color) {
    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(16),
        width: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmprestimosList(String status) {
    Stream<List<Emprestimo>> stream;
    
    if (status == 'todos') {
      stream = _emprestimoService.listarEmprestimos();
    } else if (status == 'ativo') {
      stream = _emprestimoService.listarEmprestimosAtivos();
    } else {
      stream = _emprestimoService.listarEmprestimos();
    }

    return StreamBuilder<List<Emprestimo>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Erro: ${snapshot.error}'),
          );
        }

        List<Emprestimo> emprestimos = snapshot.data ?? [];

        // Filtrar por status se necessário
        if (status != 'todos' && status != 'ativo') {
          emprestimos = emprestimos.where((e) => e.status == status).toList();
        }

        // Aplicar busca
        if (_termoBusca.isNotEmpty) {
          emprestimos = emprestimos.where((e) =>
              e.solicitante.toLowerCase().contains(_termoBusca) ||
              e.nomeAtivo.toLowerCase().contains(_termoBusca) ||
              e.responsavelEmprestimo.toLowerCase().contains(_termoBusca)).toList();
        }

        if (emprestimos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Nenhum empréstimo encontrado',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: emprestimos.length,
          itemBuilder: (context, index) {
            return _buildEmprestimoCard(emprestimos[index]);
          },
        );
      },
    );
  }

  Widget _buildEmprestimoCard(Emprestimo emprestimo) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    Color statusColor = _getStatusColor(emprestimo.status);
    IconData statusIcon = _getStatusIcon(emprestimo.status);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: () => _mostrarDetalhesEmprestimo(emprestimo),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          emprestimo.nomeAtivo,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Solicitante: ${emprestimo.solicitante}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 16, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          _getStatusText(emprestimo.status),
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Emprestado em: ${dateFormat.format(emprestimo.dataEmprestimo)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              if (emprestimo.dataDevolucaoPrevista != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.event, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Devolução prevista: ${dateFormat.format(emprestimo.dataDevolucaoPrevista!)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
              if (emprestimo.status == 'ativo' || emprestimo.status == 'atrasado') ...[
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => _abrirDialogDevolucao(emprestimo),
                  icon: const Icon(Icons.assignment_return, size: 16),
                  label: const Text('Registrar Devolução'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 36),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'ativo':
        return Colors.green;
      case 'devolvido':
        return Colors.grey;
      case 'atrasado':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'ativo':
        return Icons.access_time;
      case 'devolvido':
        return Icons.check_circle;
      case 'atrasado':
        return Icons.warning;
      default:
        return Icons.help;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'ativo':
        return 'Ativo';
      case 'devolvido':
        return 'Devolvido';
      case 'atrasado':
        return 'Atrasado';
      default:
        return 'Desconhecido';
    }
  }

  void _abrirDialogNovoEmprestimo() {
    showDialog(
      context: context,
      builder: (context) => EmprestimoFormDialog(
        onSave: (emprestimo) async {
          try {
            await _emprestimoService.criarEmprestimo(emprestimo);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Empréstimo registrado com sucesso!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Erro ao registrar empréstimo: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _abrirDialogDevolucao(Emprestimo emprestimo) {
    showDialog(
      context: context,
      builder: (context) => DevolucaoDialog(
        emprestimo: emprestimo,
        onDevolver: (responsavel) async {
          try {
            await _emprestimoService.devolverEmprestimo(
              emprestimo.id,
              responsavel,
            );
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Devolução registrada com sucesso!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Erro ao registrar devolução: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _mostrarDetalhesEmprestimo(Emprestimo emprestimo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Detalhes do Empréstimo',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _buildDetailRow('Ativo', emprestimo.nomeAtivo),
              _buildDetailRow('Solicitante', emprestimo.solicitante),
              _buildDetailRow('E-mail', emprestimo.emailSolicitante),
              _buildDetailRow('Telefone', emprestimo.telefone),
              _buildDetailRow('Data do Empréstimo', 
                DateFormat('dd/MM/yyyy HH:mm').format(emprestimo.dataEmprestimo)),
              if (emprestimo.dataDevolucaoPrevista != null)
                _buildDetailRow('Devolução Prevista', 
                  DateFormat('dd/MM/yyyy').format(emprestimo.dataDevolucaoPrevista!)),
              if (emprestimo.dataDevolucaoReal != null)
                _buildDetailRow('Devolução Realizada', 
                  DateFormat('dd/MM/yyyy HH:mm').format(emprestimo.dataDevolucaoReal!)),
              _buildDetailRow('Status', _getStatusText(emprestimo.status),
                  valueColor: _getStatusColor(emprestimo.status)),
              _buildDetailRow('Responsável pelo Empréstimo', emprestimo.responsavelEmprestimo),
              if (emprestimo.responsavelDevolucao != null)
                _buildDetailRow('Responsável pela Devolução', emprestimo.responsavelDevolucao!),
              if (emprestimo.observacoes != null && emprestimo.observacoes!.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Observações:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(emprestimo.observacoes!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: valueColor ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}