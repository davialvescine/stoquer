/*
 * TELA DE GESTÃO DE LOCALIZAÇÕES
 * 
 * Gerencia localizações físicas do sistema Stoquer.
 * Permite cadastro de escritórios, armazéns, lojas e outros locais.
 */

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LocationsScreen extends StatefulWidget {
  const LocationsScreen({super.key});

  @override
  State<LocationsScreen> createState() => _LocationsScreenState();
}

class _LocationsScreenState extends State<LocationsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _responsibleController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  
  String _locationType = 'Escritório';
  bool _isActive = true;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _responsibleController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveLocation() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('locations').add({
          'name': _nameController.text,
          'address': _addressController.text,
          'type': _locationType,
          'responsible': _responsibleController.text,
          'phone': _phoneController.text,
          'notes': _notesController.text,
          'isActive': _isActive,
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Localização salva com sucesso!')),
        );

        // Limpar campos
        _nameController.clear();
        _addressController.clear();
        _responsibleController.clear();
        _phoneController.clear();
        _notesController.clear();
        setState(() {
          _locationType = 'Escritório';
          _isActive = true;
        });
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar localização: $e')),
        );
      }
    }
  }

  Future<void> _deleteLocation(String locationId) async {
    try {
      await FirebaseFirestore.instance
          .collection('locations')
          .doc(locationId)
          .delete();
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Localização excluída com sucesso!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir localização: $e')),
      );
    }
  }

  IconData _getLocationIcon(String type) {
    switch (type) {
      case 'Escritório':
        return Icons.business;
      case 'Armazém':
        return Icons.warehouse;
      case 'Loja':
        return Icons.store;
      case 'Residência':
        return Icons.home;
      case 'Cliente':
        return Icons.person;
      case 'Outro':
        return Icons.location_on;
      default:
        return Icons.place;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Localizações'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Row(
        children: [
          // Formulário lateral
          Container(
            width: 350,
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nova Localização',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nome da Localização',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o nome da localização';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _locationType,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de Localização',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Escritório', child: Text('Escritório')),
                        DropdownMenuItem(value: 'Armazém', child: Text('Armazém')),
                        DropdownMenuItem(value: 'Loja', child: Text('Loja')),
                        DropdownMenuItem(value: 'Residência', child: Text('Residência')),
                        DropdownMenuItem(value: 'Cliente', child: Text('Cliente')),
                        DropdownMenuItem(value: 'Outro', child: Text('Outro')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _locationType = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Endereço',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _responsibleController,
                      decoration: const InputDecoration(
                        labelText: 'Responsável',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Telefone',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Observações',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Ativa'),
                      value: _isActive,
                      onChanged: (bool value) {
                        setState(() {
                          _isActive = value;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saveLocation,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('Salvar Localização'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Lista de localizações
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('locations')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final locations = snapshot.data!.docs;

                if (locations.isEmpty) {
                  return const Center(
                    child: Text('Nenhuma localização cadastrada'),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: locations.length,
                  itemBuilder: (context, index) {
                    final location = locations[index];
                    final data = location.data() as Map<String, dynamic>;

                    return Card(
                      elevation: 4,
                      child: InkWell(
                        onTap: () {
                          // Mostrar detalhes da localização
                          _showLocationDetails(location.id, data);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _getLocationIcon(data['type'] ?? 'Outro'),
                                size: 40,
                                color: data['isActive'] ?? false
                                    ? Colors.blue
                                    : Colors.grey,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                data['name'] ?? '',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                data['type'] ?? '',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 20),
                                    onPressed: () {
                                      // Implementar edição
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, size: 20),
                                    onPressed: () {
                                      _confirmDelete(location.id);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showLocationDetails(String locationId, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(_getLocationIcon(data['type'] ?? 'Outro')),
            const SizedBox(width: 8),
            Text(data['name'] ?? ''),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Tipo', data['type'] ?? '-'),
            _buildDetailRow('Endereço', data['address'] ?? '-'),
            _buildDetailRow('Responsável', data['responsible'] ?? '-'),
            _buildDetailRow('Telefone', data['phone'] ?? '-'),
            _buildDetailRow('Observações', data['notes'] ?? '-'),
            _buildDetailRow(
              'Status',
              data['isActive'] ?? false ? 'Ativa' : 'Inativa',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String locationId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text(
          'Tem certeza que deseja excluir esta localização?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteLocation(locationId);
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}