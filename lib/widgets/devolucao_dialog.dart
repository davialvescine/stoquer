// lib/widgets/devolucao_dialog.dart

import 'package:flutter/material.dart';
// SOLUÇÃO: Importa o modelo Emprestimo do local correto.
import 'package:stoquer/models/emprestimo.dart';

class DevolucaoDialog extends StatelessWidget {
  final Emprestimo emprestimo;
  final VoidCallback onConfirm;

  const DevolucaoDialog({
    super.key,
    required this.emprestimo,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirmar Devolução'),
      // SOLUÇÃO: Agora o campo 'ativoNome' é encontrado corretamente.
      content: Text('Você confirma a devolução do ativo "${emprestimo.ativoNome}"?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            onConfirm();
            Navigator.of(context).pop();
          },
          child: const Text('Confirmar'),
        ),
      ],
    );
  }
}