import 'package:flutter/material.dart';

class AddEditKitScreen extends StatelessWidget {
  const AddEditKitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar/Editar Kit'),
      ),
      body: const Center(
        child: Text('Formulário de Adicionar/Editar Kit'),
      ),
    );
  }
}