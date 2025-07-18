import 'package:flutter/material.dart';

class KitListScreen extends StatelessWidget {
  const KitListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kits'),
      ),
      body: const Center(
        child: Text('Tela de Lista de Kits'),
      ),
    );
  }
}
