import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stoquer/models/ativo.dart';
import 'package:stoquer/models/emprestimo.dart';
import 'package:stoquer/services/emprestimo_service.dart';

class EmprestimoFormDialog extends StatefulWidget {
  final Ativo ativo;
  const EmprestimoFormDialog({super.key, required this.ativo});

  @override
  State<EmprestimoFormDialog> createState() => _EmprestimoFormDialogState();
}

class _EmprestimoFormDialogState extends State<EmprestimoFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emprestimoService = EmprestimoService();
  final _solicitanteController = TextEditingController();
  DateTime? _dataPrevistaDevolucao;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Emprestar: ${widget.ativo.nome}'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _solicitanteController,
              decoration: const InputDecoration(labelText: 'Nome do Solicitante'),
              validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(_dataPrevistaDevolucao == null
                  ? 'Data Prevista da Devolução'
                  : 'Devolver em: ${DateFormat('dd/MM/yyyy').format(_dataPrevistaDevolucao!)}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  setState(() => _dataPrevistaDevolucao = pickedDate);
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        FilledButton(
          onPressed: () async {
            if (_formKey.currentState!.validate() && _dataPrevistaDevolucao != null) {
              
              final novoEmprestimo = Emprestimo(
                id: '', // Firestore vai gerar o ID
                ativoId: widget.ativo.id,
                ativoNome: widget.ativo.nome,
                usuarioId: 'id_do_solicitante_aqui',
                usuarioNome: _solicitanteController.text,
                dataEmprestimo: DateTime.now(),
                dataPrevistaDevolucao: _dataPrevistaDevolucao!,
                status: 'ativo',
                responsavelEmprestimo: 'id_do_admin_logado_aqui',
              );

              await _emprestimoService.criarEmprestimo(novoEmprestimo);
              
              // SOLUÇÃO: Verificação de segurança adicionada.
              if (!mounted) return;
              Navigator.pop(context);
            }
          },
          child: const Text('Confirmar'),
        ),
      ],
    );
  }
}

  