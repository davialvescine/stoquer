// widgets/emprestimo_form_dialog.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/emprestimo.dart';
import '../models/ativo.dart';
import '../services/ativo_service.dart';

class EmprestimoFormDialog extends StatefulWidget {
  final Function(Emprestimo) onSave;
  final Emprestimo? emprestimo;

  const EmprestimoFormDialog({
    Key? key,
    required this.onSave,
    this.emprestimo,
  }) : super(key: key);

  @override
  State<EmprestimoFormDialog> createState() => _EmprestimoFormDialogState();
}

class _EmprestimoFormDialogState extends State<EmprestimoFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _solicitanteController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _observacoesController = TextEditingController();
  final _responsavelController = TextEditingController();
  
  DateTime _dataEmprestimo = DateTime.now();
  DateTime? _dataDevolucaoPrevista;
  Ativo? _ativoSelecionado;
  final AtivoService _ativoService = AtivoService();

  @override
  void initState() {
    super.initState();
    if (widget.emprestimo != null) {
      _carregarDadosEmprestimo();
    }
  }

  void _carregarDadosEmprestimo() {
    final emp = widget.emprestimo!;
    _solicitanteController.text = emp.solicitante;
    _emailController.text = emp.emailSolicitante;
    _telefoneController.text = emp.telefone;
    _observacoesController.text = emp.observacoes ?? '';
    _responsavelController.text = emp.responsavelEmprestimo;
    _dataEmprestimo = emp.dataEmprestimo;
    _dataDevolucaoPrevista = emp.dataDevolucaoPrevista;
  }

  @override
  void dispose() {
    _solicitanteController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _observacoesController.dispose();
    _responsavelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.emprestimo == null ? 'Novo Empréstimo' : 'Editar Empréstimo'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Seleção de Ativo
              StreamBuilder<List<Ativo>>(
                stream: _ativoService.listarAtivosDisponiveis(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  final ativos = snapshot.data!;
                  
                  if (ativos.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Nenhum ativo disponível para empréstimo',
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  return DropdownButtonFormField<Ativo>(
                    value: _ativoSelecionado,
                    decoration: const InputDecoration(
                      labelText: 'Ativo *',
                      prefixIcon: Icon(Icons.devices),
                    ),
                    items: ativos.map((ativo) {
                      return DropdownMenuItem(
                        value: ativo,
                        child: Text('${ativo.nome} - ${ativo.codigo}'),
                      );
                    }).toList(),
                    onChanged: widget.emprestimo == null
                        ? (value) {
                            setState(() {
                              _ativoSelecionado = value;
                            });
                          }
                        : null,
                    validator: (value) {
                      if (value == null && widget.emprestimo == null) {
                        return 'Selecione um ativo';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 16),

              // Dados do Solicitante
              TextFormField(
                controller: _solicitanteController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Solicitante *',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o nome do solicitante';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-mail *',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o e-mail';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'E-mail inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _telefoneController,
                decoration: const InputDecoration(
                  labelText: 'Telefone *',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o telefone';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Data do Empréstimo
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Data do Empréstimo'),
                subtitle: Text(DateFormat('dd/MM/yyyy').format(_dataEmprestimo)),
                onTap: widget.emprestimo == null
                    ? () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _dataEmprestimo,
                          firstDate: DateTime.now().subtract(const Duration(days: 30)),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() {
                            _dataEmprestimo = date;
                          });
                        }
                      }
                    : null,
              ),

              // Data de Devolução Prevista
              ListTile(
                leading: const Icon(Icons.event),
                title: const Text('Data de Devolução Prevista'),
                subtitle: Text(_dataDevolucaoPrevista != null
                    ? DateFormat('dd/MM/yyyy').format(_dataDevolucaoPrevista!)
                    : 'Não definida'),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _dataDevolucaoPrevista ?? DateTime.now().add(const Duration(days: 7)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() {
                      _dataDevolucaoPrevista = date;
                    });
                  }
                },
                trailing: _dataDevolucaoPrevista != null
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _dataDevolucaoPrevista = null;
                          });
                        },
                      )
                    : null,
              ),
              const SizedBox(height: 16),

              // Responsável
              TextFormField(
                controller: _responsavelController,
                decoration: const InputDecoration(
                  labelText: 'Responsável pelo Empréstimo *',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o responsável';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Observações
              TextFormField(
                controller: _observacoesController,
                decoration: const InputDecoration(
                  labelText: 'Observações',
                  prefixIcon: Icon(Icons.notes),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _salvarEmprestimo,
          child: const Text('Salvar'),
        ),
      ],
    );
  }

  void _salvarEmprestimo() {
    if (_formKey.currentState!.validate()) {
      final emprestimo = Emprestimo(
        id: widget.emprestimo?.id ?? '',
        ativoId: widget.emprestimo?.ativoId ?? _ativoSelecionado!.id,
        nomeAtivo: widget.emprestimo?.nomeAtivo ?? _ativoSelecionado!.nome,
        solicitante: _solicitanteController.text,
        emailSolicitante: _emailController.text,
        telefone: _telefoneController.text,
        dataEmprestimo: _dataEmprestimo,
        dataDevolucaoPrevista: _dataDevolucaoPrevista,
        status: widget.emprestimo?.status ?? 'ativo',
        observacoes: _observacoesController.text.isEmpty ? null : _observacoesController.text,
        responsavelEmprestimo: _responsavelController.text,
      );

      widget.onSave(emprestimo);
      Navigator.of(context).pop();
    }
  }
}

// widgets/devolucao_dialog.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/emprestimo.dart';

class DevolucaoDialog extends StatefulWidget {
  final Emprestimo emprestimo;
  final Function(String) onDevolver;

  const DevolucaoDialog({
    Key? key,
    required this.emprestimo,
    required this.onDevolver,
  }) : super(key: key);

  @override
  State<DevolucaoDialog> createState() => _DevolucaoDialogState();
}

class _DevolucaoDialogState extends State<DevolucaoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _responsavelController = TextEditingController();
  final _observacoesController = TextEditingController();

  @override
  void dispose() {
    _responsavelController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final diasEmprestado = DateTime.now().difference(widget.emprestimo.dataEmprestimo).inDays;
    final estaAtrasado = widget.emprestimo.dataDevolucaoPrevista != null &&
        DateTime.now().isAfter(widget.emprestimo.dataDevolucaoPrevista!);

    return AlertDialog(
      title: const Text('Registrar Devolução'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Informações do Empréstimo
              Card(
                color: Colors.grey[100],
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.emprestimo.nomeAtivo,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Solicitante: ${widget.emprestimo.solicitante}'),
                      Text('Emprestado em: ${dateFormat.format(widget.emprestimo.dataEmprestimo)}'),
                      Text('Dias emprestado: $diasEmprestado'),
                      if (widget.emprestimo.dataDevolucaoPrevista != null) ...[
                        Text(
                          'Devolução prevista: ${dateFormat.format(widget.emprestimo.dataDevolucaoPrevista!)}',
                          style: TextStyle(
                            color: estaAtrasado ? Colors.red : null,
                            fontWeight: estaAtrasado ? FontWeight.bold : null,
                          ),
                        ),
                        if (estaAtrasado)
                          Text(
                            'ATRASADO ${DateTime.now().difference(widget.emprestimo.dataDevolucaoPrevista!).inDays} dias',
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Responsável pela Devolução
              TextFormField(
                controller: _responsavelController,
                decoration: const InputDecoration(
                  labelText: 'Responsável pela Devolução *',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o responsável pela devolução';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Observações
              TextFormField(
                controller: _observacoesController,
                decoration: const InputDecoration(
                  labelText: 'Observações sobre o estado do ativo',
                  prefixIcon: Icon(Icons.notes),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _confirmarDevolucao,
          child: const Text('Confirmar Devolução'),
        ),
      ],
    );
  }

  void _confirmarDevolucao() {
    if (_formKey.currentState!.validate()) {
      widget.onDevolver(_responsavelController.text);
      Navigator.of(context).pop();
    }
  }
}