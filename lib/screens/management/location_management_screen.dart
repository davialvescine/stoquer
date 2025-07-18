import 'package:flutter/material.dart';

class LocationManagementScreen extends StatelessWidget {
  const LocationManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerir Localizações'),
      ),
      body: const Center(
        child: Text('Tela de Gestão de Localizações'),
      ),
    );
  }
}