// lib/screens/emprestimos_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stoquer/models/emprestimo.dart';
import 'package:stoquer/services/emprestimo_service.dart';
import 'package:stoquer/widgets/devolucao_dialog.dart';

class EmprestimosScreen extends StatefulWidget {
  const EmprestimosScreen({super.key});
  @override
  State<EmprestimosScreen> createState() => _EmprestimosScreenState();
}
class _EmprestimosScreenState extends State<EmprestimosScreen> {
  final EmprestimoService _emprestimoService = EmprestimoService();
  void _mostrarDialogoDevolucao(Emprestimo emprestimo) { /* ...código da resposta anterior... */ }
  
  @override
  Widget build(BuildContext context) {
    // COLE AQUI O MÉTODO build COMPLETO DA RESPOSTA ANTERIOR
  }
}