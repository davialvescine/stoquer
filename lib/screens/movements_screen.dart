/*
 * TELA DE GESTÃO DE MOVIMENTAÇÕES
 * 
 * Gerencia todas as movimentações de ativos no sistema.
 * Inclui empréstimos, devoluções, transferências e histórico.
 */

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class MovementsScreen extends StatefulWidget {
  const MovementsScreen({super.key});

  @override
  State<MovementsScreen> createState() => _MovementsScreenState();
}

class _MovementsScreenState extends State<MovementsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _borrowerNameController = TextEditingController();
  final _borrowerEmailController = TextEditingController();
  final _borrowerPhoneController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime _expectedReturnDate = DateTime.now().add(const Duration(days: 7));
  final String _movementType = 'emprestimo';
  final List<Map<String, dynamic>> _selectedItems = [];

  @override
  void dispose() {
    _borrowerNameController.dispose();
    _borrowerEmailController.dispose();
    _borrowerPhoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveMovement() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedItems.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecione pelo menos um item')),
        );
        return;
      }

      try {
        // Criar movimento
        final movementRef = await FirebaseFirestore.instance.collection('movements').add({
          'type': _movementType,
          'borrowerName': _borrowerNameController.text,
          'borrowerEmail': _borrowerEmailController.text,
          'borrowerPhone': _borrowerPhoneController.text,
          'items': _selectedItems,
          'expectedReturnDate': _expectedReturnDate,
          'actualReturnDate': null,
          'notes': _notesController.text,
          'status': 'active',
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Atualizar status dos itens
        for (var item in _selectedItems) {
          if (item['type'] == 'asset') {
            await FirebaseFirestore.instance
                .collection('assets')
                .doc(item['id'])
                .update({
              'status': _movementType == 'emprestimo' ? 'emprestado' : 'disponivel',
              'currentMovement': _movementType == 'emprestimo' ? movementRef.id : null,
            });
          }
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Movimentação registrada com sucesso!')),
        );

        // Limpar formulário
        _clearForm();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao registrar movimentação: $e')),
        );
      }
    }
  }

  void _clearForm() {
    _borrowerNameController.clear();
    _borrowerEmailController.clear();
    _borrowerPhoneController.clear();
    _notesController.clear();
    setState(() {
      _selectedItems.clear();
      _expectedReturnDate = DateTime.now().add(const Duration(days: 7));
    });
  }

  Future<void> _returnItems(String movementId, List<dynamic> items) async {
    try {
      // Atualizar movimento
      await FirebaseFirestore.instance
          .collection('movements')
          .doc(movementId)
          .update({
        'status': 'returned',
        'actualReturnDate': FieldValue.serverTimestamp(),
      });

      // Atualizar status dos itens
      for (var item in items) {
        if (item['type'] == 'asset') {
          await FirebaseFirestore.instance
              .collection('assets')
              .doc(item['id'])
              .update({
            'status': 'disponivel',
            'currentMovement': null,
          });
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Itens devolvidos com sucesso!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao devolver itens: $e')),
      );
    }
  }

  void _showItemSelection() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 800,
          height: 600,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Text(
                'Selecionar Itens',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              DefaultTabController(
                length: 3,
                child: Expanded(
                  child: Column(
                    children: [
                      const TabBar(
                        tabs: [
                          Tab(text: 'Ativos'),
                          Tab(text: 'Acessórios'),
                          Tab(text: 'Kits'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            // Tab Ativos
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('assets')
                                  .where('status', isEqualTo: 'disponivel')
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
                                    final isSelected = _selectedItems.any(
                                      (item) => item['id'] == asset.id && item['type'] == 'asset',
                                    );

                                    return CheckboxListTile(
                                      title: Text(data['name'] ?? ''),
                                      subtitle: Text('${data['brand']} - ${data['model']}'),
                                      secondary: CircleAvatar(
                                        child: Text(data['tag'] ?? ''),
                                      ),
                                      value: isSelected,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          if (value ?? false) {
                                            _selectedItems.add({
                                              'id': asset.id,
                                              'type': 'asset',
                                              'name': data['name'],
                                              'tag': data['tag'],
                                            });
                                          } else {
                                            _selectedItems.removeWhere(
                                              (item) => item['id'] == asset.id && item['type'] == 'asset',
                                            );
                                          }
                                        });
                                        Navigator.pop(context);
                                        _showItemSelection();
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                            // Tab Acessórios
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('accessories')
                                  .where('quantity', isGreaterThan: 0)
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
                                    final selectedItem = _selectedItems.firstWhere(
                                      (item) => item['id'] == accessory.id && item['type'] == 'accessory',
                                      orElse: () => {'quantity': 0},
                                    );

                                    return ListTile(
                                      title: Text(data['name'] ?? ''),
                                      subtitle: Text('Disponível: ${data['quantity']}'),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.remove),
                                            onPressed: selectedItem['quantity'] > 0
                                                ? () {
                                                    setState(() {
                                                      final index = _selectedItems.indexWhere(
                                                        (item) => item['id'] == accessory.id && item['type'] == 'accessory',
                                                      );
                                                      if (index != -1) {
                                                        if (_selectedItems[index]['quantity'] == 1) {
                                                          _selectedItems.removeAt(index);
                                                        } else {
                                                          _selectedItems[index]['quantity']--;
                                                        }
                                                      }
                                                    });
                                                    Navigator.pop(context);
                                                    _showItemSelection();
                                                  }
                                                : null,
                                          ),
                                          Text('${selectedItem['quantity']}'),
                                          IconButton(
                                            icon: const Icon(Icons.add),
                                            onPressed: selectedItem['quantity'] < data['quantity']
                                                ? () {
                                                    setState(() {
                                                      final index = _selectedItems.indexWhere(
                                                        (item) => item['id'] == accessory.id && item['type'] == 'accessory',
                                                      );
                                                      if (index != -1) {
                                                        _selectedItems[index]['quantity']++;
                                                      } else {
                                                        _selectedItems.add({
                                                          'id': accessory.id,
                                                          'type': 'accessory',
                                                          'name': data['name'],
                                                          'quantity': 1,
                                                        });
                                                      }
                                                    });
                                                    Navigator.pop(context);
                                                    _showItemSelection();
                                                  }
                                                : null,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                            // Tab Kits
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('kits')
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const Center(child: CircularProgressIndicator());
                                }

                                final kits = snapshot.data!.docs;

                                return ListView.builder(
                                  itemCount: kits.length,
                                  itemBuilder: (context, index) {
                                    final kit = kits[index];
                                    final data = kit.data() as Map<String, dynamic>;
                                    final isSelected = _selectedItems.any(
                                      (item) => item['id'] == kit.id && item['type'] == 'kit',
                                    );

                                    return CheckboxListTile(
                                      title: Text(data['name'] ?? ''),
                                      subtitle: Text(data['description'] ?? ''),
                                      value: isSelected,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          if (value ?? false) {
                                            _selectedItems.add({
                                              'id': kit.id,
                                              'type': 'kit',
                                              'name': data['name'],
                                              'items': data['assets'] ?? [],
                                              'accessories': data['accessories'] ?? [],
                                            });
                                          } else {
                                            _selectedItems.removeWhere(
                                              (item) => item['id'] == kit.id && item['type'] == 'kit',
                                            );
                                          }
                                        });
                                        Navigator.pop(context);
                                        _showItemSelection();
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Fechar'),
                  ),
                ],
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
        title: const Text('Movimentações'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: DefaultTabController.of(context),
          onTap: (index) => {}, // Placeholder for tab functionality
          tabs: const [
            Tab(text: 'Novo Empréstimo'),
            Tab(text: 'Empréstimos Ativos'),
            Tab(text: 'Histórico'),
          ],
        ),
      ),
      body: DefaultTabController(
        length: 3,
        child: TabBarView(
          children: [
            // Tab Novo Empréstimo
            _buildNewMovementForm(),
            // Tab Empréstimos Ativos
            _buildActiveMovements(),
            // Tab Histórico
            _buildMovementHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildNewMovementForm() {
    return Row(
      children: [
        // Formulário
        Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          color: Colors.grey[100],
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Novo Empréstimo',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _borrowerNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome do Responsável',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o nome';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _borrowerEmailController,
                    decoration: const InputDecoration(
                      labelText: 'E-mail',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o e-mail';
                      }
                      if (!value.contains('@')) {
                        return 'E-mail inválido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _borrowerPhoneController,
                    decoration: const InputDecoration(
                      labelText: 'Telefone',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _expectedReturnDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() {
                          _expectedReturnDate = date;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Data Prevista de Devolução',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        DateFormat('dd/MM/yyyy').format(_expectedReturnDate),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Observações',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.note),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _showItemSelection,
                    icon: const Icon(Icons.add),
                    label: Text('Adicionar Itens (${_selectedItems.length})'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_selectedItems.isNotEmpty) ...[
                    const Text(
                      'Itens Selecionados:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ..._selectedItems.map((item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Chip(
                            label: Text(
                              item['type'] == 'accessory'
                                  ? '${item['name']} (${item['quantity']}x)'
                                  : item['name'],
                            ),
                            deleteIcon: const Icon(Icons.close, size: 18),
                            onDeleted: () {
                              setState(() {
                                _selectedItems.remove(item);
                              });
                            },
                          ),
                        )),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _saveMovement,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.green,
                    ),
                    child: const Text(
                      'Registrar Empréstimo',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Preview
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Resumo do Empréstimo',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSummaryRow(
                          'Responsável',
                          _borrowerNameController.text.isEmpty
                              ? '-'
                              : _borrowerNameController.text,
                        ),
                        _buildSummaryRow(
                          'E-mail',
                          _borrowerEmailController.text.isEmpty
                              ? '-'
                              : _borrowerEmailController.text,
                        ),
                        _buildSummaryRow(
                          'Telefone',
                          _borrowerPhoneController.text.isEmpty
                              ? '-'
                              : _borrowerPhoneController.text,
                        ),
                        _buildSummaryRow(
                          'Data de Devolução',
                          DateFormat('dd/MM/yyyy').format(_expectedReturnDate),
                        ),
                        _buildSummaryRow(
                          'Total de Itens',
                          '${_selectedItems.length}',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveMovements() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('movements')
          .where('status', isEqualTo: 'active')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Erro: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final movements = snapshot.data!.docs;

        if (movements.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, size: 64, color: Colors.green),
                SizedBox(height: 16),
                Text(
                  'Nenhum empréstimo ativo',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: movements.length,
          itemBuilder: (context, index) {
            final movement = movements[index];
            final data = movement.data() as Map<String, dynamic>;
            final expectedReturn = (data['expectedReturnDate'] as Timestamp).toDate();
            final isLate = expectedReturn.isBefore(DateTime.now());

            return Card(
              color: isLate ? Colors.red[50] : null,
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: isLate ? Colors.red : Colors.blue,
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                title: Text(
                  data['borrowerName'] ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data['borrowerEmail'] ?? ''),
                    Text(
                      'Devolução: ${DateFormat('dd/MM/yyyy').format(expectedReturn)}',
                      style: TextStyle(
                        color: isLate ? Colors.red : null,
                        fontWeight: isLate ? FontWeight.bold : null,
                      ),
                    ),
                    if (isLate)
                      Text(
                        'ATRASADO',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
                trailing: ElevatedButton.icon(
                  onPressed: () => _confirmReturn(movement.id, data['items']),
                  icon: const Icon(Icons.check),
                  label: const Text('Devolver'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Itens Emprestados:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ...List.generate(
                          (data['items'] as List).length,
                          (index) {
                            final item = data['items'][index];
                            return ListTile(
                              dense: true,
                              leading: Icon(
                                item['type'] == 'asset'
                                    ? Icons.devices
                                    : item['type'] == 'accessory'
                                        ? Icons.extension
                                        : Icons.inventory_2,
                                size: 20,
                              ),
                              title: Text(
                                item['type'] == 'accessory'
                                    ? '${item['name']} (${item['quantity']}x)'
                                    : item['name'],
                              ),
                              subtitle: item['tag'] != null
                                  ? Text('Tag: ${item['tag']}')
                                  : null,
                            );
                          },
                        ),
                        if (data['notes'] != null && data['notes'].isNotEmpty) ...[
                          const SizedBox(height: 8),
                          const Text(
                            'Observações:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(data['notes']),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMovementHistory() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('movements')
          .where('status', isEqualTo: 'returned')
          .orderBy('actualReturnDate', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Erro: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final movements = snapshot.data!.docs;

        if (movements.isEmpty) {
          return const Center(
            child: Text('Nenhum histórico de movimentação'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: movements.length,
          itemBuilder: (context, index) {
            final movement = movements[index];
            final data = movement.data() as Map<String, dynamic>;
            final createdAt = (data['createdAt'] as Timestamp).toDate();
            final returnedAt = (data['actualReturnDate'] as Timestamp).toDate();

            return Card(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.history, color: Colors.white),
                ),
                title: Text(data['borrowerName'] ?? ''),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${(data['items'] as List).length} itens'),
                    Text(
                      'Emprestado: ${DateFormat('dd/MM/yyyy HH:mm').format(createdAt)}',
                    ),
                    Text(
                      'Devolvido: ${DateFormat('dd/MM/yyyy HH:mm').format(returnedAt)}',
                    ),
                  ],
                ),
                onTap: () => _showMovementDetails(data),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }

  void _confirmReturn(String movementId, List<dynamic> items) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Devolução'),
        content: const Text(
          'Confirma a devolução de todos os itens deste empréstimo?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _returnItems(movementId, items);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _showMovementDetails(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detalhes da Movimentação'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Responsável', data['borrowerName'] ?? '-'),
            _buildDetailRow('E-mail', data['borrowerEmail'] ?? '-'),
            _buildDetailRow('Telefone', data['borrowerPhone'] ?? '-'),
            const SizedBox(height: 16),
            const Text(
              'Itens:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...List.generate(
              (data['items'] as List).length,
              (index) {
                final item = data['items'][index];
                return Text('• ${item['name']}');
              },
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
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }
}