import 'package:flutter/material.dart';

class CategoryManagementScreen extends StatelessWidget {
  const CategoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerir Categorias'),
      ),
      body: const Center(
        child: Text('Tela de Gestão de Categorias'),
      ),
    );
  }
}
