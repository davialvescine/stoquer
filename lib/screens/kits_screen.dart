/*
 * TELA DE GESTÃO DE KITS
 * 
 * Gerencia kits compostos por múltiplos ativos e acessórios.
 * Permite criar, editar e gerenciar conjuntos pré-definidos de itens.
 */

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class KitsScreen extends StatefulWidget {
  const KitsScreen({super.key});

  @override
  State<KitsScreen> createState() => _KitsScreenState();
}

class _KitsScreenState extends State<KitsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  final List<Map<String, dynamic>> _selectedAssets = [];
  final List<Map<String, dynamic>> _selectedAccessories = [];
  String? _selectedCategory;
  String? _selectedLocation;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveKit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedAssets.isEmpty && _selectedAccessories.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Adicione pelo menos um ativo ou acessório ao kit'),
          ),
        );
        return;
      }

      try {
        await FirebaseFirestore.instance.collection('kits').add({
          'name': _nameController.text,
          'description': _descriptionController.text,
          'assets': _selectedAssets.map((asset) => asset['id']).toList(),
          'accessories': _selectedAccessories.map((acc) => {
            'id': acc['id'],
            'quantity': acc['quantity'],
          }).toList(),
          'category': _selectedCategory,
          'location': _selectedLocation,
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kit salvo com sucesso!')),
        );

        // Limpar campos
        _nameController.clear();
        _descriptionController.clear();
        setState(() {
          _selectedAssets.clear();
          _selectedAccessories.clear();
          _selectedCategory = null;
          _selectedLocation = null;
        });
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar kit: $e')),
        );
      }
    }
  }

  Future<void> _deleteKit(String kitId) async {
    try {
      await FirebaseFirestore.instance
          .collection('kits')
          .doc(kitId)
          .delete();
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kit excluído com sucesso!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir kit: $e')),
      );
    }
  }

  void _showAssetSelection() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 600,
          height: 400,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                'Selecionar Ativos',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('assets')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final assets = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: assets.length,
                      itemBuilder: (context, index) {
                        final asset = assets[index];
                        final data = asset.data() as Map<String, dynamic>;
                        final isSelected = _selectedAssets
                            .any((a) => a['id'] == asset.id);

                        return CheckboxListTile(
                          title: Text(data['name'] ?? ''),
                          subtitle: Text(data['brand'] ?? ''),
                          value: isSelected,
                          onChanged: (bool? value) {
                            setState(() {
                              if (value ?? false) {
                                _selectedAssets.add({
                                  'id': asset.id,
                                  'name': data['name'],
                                });
                              } else {
                                _selectedAssets.removeWhere(
                                  (a) => a['id'] == asset.id,
                                );
                              }
                            });
                            Navigator.pop(context);
                            _showAssetSelection();
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fechar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAccessorySelection() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 600,
          height: 400,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                'Selecionar Acessórios',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('accessories')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final accessories = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: accessories.length,
                      itemBuilder: (context, index) {
                        final accessory = accessories[index];
                        final data = accessory.data() as Map<String, dynamic>;
                        final selected = _selectedAccessories
                            .firstWhere(
                              (a) => a['id'] == accessory.id,
                              orElse: () => {'quantity': 0},
                            );

                        return ListTile(
                          title: Text(data['name'] ?? ''),
                          subtitle: Text(
                            'Disponível: ${data['quantity'] ?? 0}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: selected['quantity'] > 0
                                    ? () {
                                        setState(() {
                                          final index = _selectedAccessories
                                              .indexWhere(
                                            (a) => a['id'] == accessory.id,
                                          );
                                          if (index != -1) {
                                            if (_selectedAccessories[index]
                                                    ['quantity'] ==
                                                1) {
                                              _selectedAccessories
                                                  .removeAt(index);
                                            } else {
                                              _selectedAccessories[index]
                                                  ['quantity']--;
                                            }
                                          }
                                        });
                                        Navigator.pop(context);
                                        _showAccessorySelection();
                                      }
                                    : null,
                              ),
                              Text('${selected['quantity']}'),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  setState(() {
                                    final index = _selectedAccessories
                                        .indexWhere(
                                      (a) => a['id'] == accessory.id,
                                    );
                                    if (index != -1) {
                                      _selectedAccessories[index]['quantity']++;
                                    } else {
                                      _selectedAccessories.add({
                                        'id': accessory.id,
                                        'name': data['name'],
                                        'quantity': 1,
                                      });
                                    }
                                  });
                                  Navigator.pop(context);
                                  _showAccessorySelection();
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fechar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kits'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Row(
        children: [
          // Formulário lateral
          Container(
            width: 400,
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Novo Kit',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nome do Kit',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o nome do kit';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Descrição',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('categories')
                          .where('isActive', isEqualTo: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator();
                        }
                        
                        final categories = snapshot.data!.docs;
                        
                        return DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: const InputDecoration(
                            labelText: 'Categoria',
                            border: OutlineInputBorder(),
                          ),
                          items: categories.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            return DropdownMenuItem(
                              value: doc.id,
                              child: Text(data['name'] ?? ''),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value;
                            });
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('locations')
                          .where('isActive', isEqualTo: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator();
                        }
                        
                        final locations = snapshot.data!.docs;
                        
                        return DropdownButtonFormField<String>(
                          value: _selectedLocation,
                          decoration: const InputDecoration(
                            labelText: 'Localização',
                            border: OutlineInputBorder(),
                          ),
                          items: locations.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            return DropdownMenuItem(
                              value: doc.id,
                              child: Text(data['name'] ?? ''),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedLocation = value;
                            });
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Itens do Kit',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _showAssetSelection,
                            icon: const Icon(Icons.devices),
                            label: Text('Adicionar Ativos (${_selectedAssets.length})'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _showAccessorySelection,
                            icon: const Icon(Icons.extension),
                            label: Text('Adicionar Acessórios (${_selectedAccessories.length})'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_selectedAssets.isNotEmpty) ...[
                      const Text('Ativos Selecionados:'),
                      const SizedBox(height: 8),
                      ..._selectedAssets.map((asset) => Chip(
                            label: Text(asset['name']),
                            onDeleted: () {
                              setState(() {
                                _selectedAssets.removeWhere(
                                  (a) => a['id'] == asset['id'],
                                );
                              });
                            },
                          )),
                      const SizedBox(height: 16),
                    ],
                    if (_selectedAccessories.isNotEmpty) ...[
                      const Text('Acessórios Selecionados:'),
                      const SizedBox(height: 8),
                      ..._selectedAccessories.map((acc) => Chip(
                            label: Text('${acc['name']} (${acc['quantity']}x)'),
                            onDeleted: () {
                              setState(() {
                                _selectedAccessories.removeWhere(
                                  (a) => a['id'] == acc['id'],
                                );
                              });
                            },
                          )),
                      const SizedBox(height: 16),
                    ],
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saveKit,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('Salvar Kit'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Lista de kits
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('kits')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final kits = snapshot.data!.docs;

                if (kits.isEmpty) {
                  return const Center(
                    child: Text('Nenhum kit cadastrado'),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: kits.length,
                  itemBuilder: (context, index) {
                    final kit = kits[index];
                    final data = kit.data() as Map<String, dynamic>;
                    final assetCount = (data['assets'] as List?)?.length ?? 0;
                    final accessoryCount = (data['accessories'] as List?)?.length ?? 0;

                    return Card(
                      elevation: 4,
                      child: InkWell(
                        onTap: () {
                          _showKitDetails(kit.id, data);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.inventory_2,
                                    size: 32,
                                    color: Colors.deepPurple,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      data['name'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                data['description'] ?? '',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Spacer(),
                              Row(
                                children: [
                                  Chip(
                                    label: Text('$assetCount ativos'),
                                  ),
                                  const SizedBox(width: 8),
                                  Chip(
                                    label: Text('$accessoryCount acessórios'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 20),
                                    onPressed: () {
                                      /// Implementar edição
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, size: 20),
                                    onPressed: () {
                                      _confirmDelete(kit.id);
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

  void _showKitDetails(String kitId, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 600,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.inventory_2, size: 32, color: Colors.deepPurple),
                  const SizedBox(width: 12),
                  Text(
                    data['name'] ?? '',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                data['description'] ?? 'Sem descrição',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              const Text(
                'Composição do Kit:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Mostrar lista detalhada de ativos e acessórios
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fechar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(String kitId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text(
          'Tem certeza que deseja excluir este kit?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteKit(kitId);
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}