//TELA DE GESTÃO DE ACESSÓRIOS

 //Esta tela permite o gerenciamento completo de acessórios do sistema Stoquer.
// Inclui funcionalidades de cadastro, edição, listagem e controle de estoque.
 // FUNCIONALIDADES PRINCIPAIS:
 // - Cadastro de novos acessórios com validação completa
 // - Listagem em tempo real com StreamBuilder
 // - Controle de quantidade e estoque mínimo
 // - Categorização e compatibilidade com ativos
 //- Marcação de itens consumíveis
 // - Operações de edição de quantidade
 // - Exclusão com confirmação
 // - Alertas de estoque baixo//

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// WIDGET PRINCIPAL: AccessoriesScreen
// StatefulWidget que gerencia toda a interface de acessórios.
 // Utiliza layout com formulário lateral e lista principal.

class AccessoriesScreen extends StatefulWidget {
  const AccessoriesScreen({super.key});

  @override
  State<AccessoriesScreen> createState() => _AccessoriesScreenState();
}

// ESTADO DA TELA: _AccessoriesScreenState
 // Gerencia todo o estado da tela de gestão de acessórios.
 // Controla formulário, dados, validações e interações do usuário.

class _AccessoriesScreenState extends State<AccessoriesScreen> {
  // === CONTROLADORES DE FORMULÁRIO ===
  // Chave global para validação do formulário
  final _formKey = GlobalKey<FormState>();
  
  // Controladores para os campos de texto
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController();
  final _minStockController = TextEditingController();
  
  // === ESTADO DO FORMULÁRIO ===
  // Categoria selecionada para o acessório
  String? _selectedCategory;
  
  // Ativo compatível selecionado (opcional)
  String? _selectedAsset;
  
  // Flag indicando se o item é consumível
  bool _isConsumable = false;

  // MÉTODO DO CICLO DE VIDA: dispose
   
   // Libera recursos dos controladores para evitar vazamentos de memória.
   // Executado quando o widget é removido da árvore de widgets.
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _minStockController.dispose();
    super.dispose();
  }

  /*
   * MÉTODO: _saveAccessory
   * 
   * Salva um novo acessório no Firestore após validação.
   * Inclui tratamento de erros e feedback visual para o usuário.
   * 
   * VALIDAÇÕES:
   * - Campos obrigatórios preenchidos
   * - Formatos numéricos corretos
   * - Valores positivos para quantidade e estoque
   */
  Future<void> _saveAccessory() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Criar documento no Firestore com todos os dados do acessório
        await FirebaseFirestore.instance.collection('accessories').add({
          'name': _nameController.text.trim(),
          'description': _descriptionController.text.trim(),
          'quantity': int.parse(_quantityController.text),
          'minStock': int.parse(_minStockController.text),
          'category': _selectedCategory,
          'compatibleAsset': _selectedAsset,
          'isConsumable': _isConsumable,
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Acessório salvo com sucesso!')),
        );

        // === LIMPAR FORMULÁRIO APÓS SUCESSO ===
        _nameController.clear();
        _descriptionController.clear();
        _quantityController.clear();
        _minStockController.clear();
        setState(() {
          _selectedCategory = null;
          _selectedAsset = null;
          _isConsumable = false;
        });
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar acessório: $e')),
        );
      }
    }
  }

  /*
   * MÉTODO: _updateQuantity
   * 
   * Atualiza a quantidade de um acessório no estoque.
   * Permite incremento e decremento direto da quantidade.
   * 
   * PARÂMETROS:
   * - accessoryId: ID do acessório a ser atualizado
   * - newQuantity: Nova quantidade a ser definida
   */
  Future<void> _updateQuantity(String accessoryId, int newQuantity) async {
    try {
      // Atualizar quantidade no Firestore
      await FirebaseFirestore.instance
          .collection('accessories')
          .doc(accessoryId)
          .update({'quantity': newQuantity});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar quantidade: $e')),
      );
    }
  }

  /*
   * MÉTODO: _deleteAccessory
   * 
   * Exclui um acessório do sistema após confirmação.
   * Remove permanentemente o documento do Firestore.
   * 
   * PARÂMETROS:
   * - accessoryId: ID do acessório a ser excluído
   */
  Future<void> _deleteAccessory(String accessoryId) async {
    try {
      // Excluir documento do Firestore
      await FirebaseFirestore.instance
          .collection('accessories')
          .doc(accessoryId)
          .delete();
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Acessório excluído com sucesso!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir acessório: $e')),
      );
    }
  }

  /*
   * MÉTODO: build
   * 
   * Constrói a interface principal da tela de acessórios.
   * Layout com formulário lateral e lista principal de acessórios.
   * 
   * ESTRUTURA:
   * - AppBar com título
   * - Row com formulário lateral (350px) e lista expandida
   * - StreamBuilder para dados em tempo real
   * - Cards de acessórios com controles de quantidade
   */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestão de Acessórios'),
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
                      'Novo Acessório',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nome do Acessório',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o nome do acessório';
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
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _quantityController,
                            decoration: const InputDecoration(
                              labelText: 'Quantidade',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Insira a quantidade';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Insira um número válido';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _minStockController,
                            decoration: const InputDecoration(
                              labelText: 'Estoque Mínimo',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Insira o estoque mínimo';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Insira um número válido';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
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
                          .collection('assets')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator();
                        }
                        
                        final assets = snapshot.data!.docs;
                        
                        return DropdownButtonFormField<String>(
                          value: _selectedAsset,
                          decoration: const InputDecoration(
                            labelText: 'Ativo Compatível (Opcional)',
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('Nenhum'),
                            ),
                            ...assets.map((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              return DropdownMenuItem(
                                value: doc.id,
                                child: Text(data['name'] ?? ''),
                              );
                            }),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedAsset = value;
                            });
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Consumível'),
                      subtitle: const Text('Item que é consumido com o uso'),
                      value: _isConsumable,
                      onChanged: (bool value) {
                        setState(() {
                          _isConsumable = value;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saveAccessory,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('Salvar Acessório'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Lista de acessórios
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('accessories')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final accessories = snapshot.data!.docs;

                if (accessories.isEmpty) {
                  return const Center(
                    child: Text('Nenhum acessório cadastrado'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: accessories.length,
                  itemBuilder: (context, index) {
                    final accessory = accessories[index];
                    final data = accessory.data() as Map<String, dynamic>;
                    final quantity = data['quantity'] ?? 0;
                    final minStock = data['minStock'] ?? 0;
                    final isLowStock = quantity <= minStock;

                    return Card(
                      color: isLowStock ? Colors.orange[50] : null,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isLowStock ? Colors.orange : Colors.blue,
                          child: Icon(
                            data['isConsumable'] ?? false
                                ? Icons.battery_charging_full
                                : Icons.extension,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(data['name'] ?? ''),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(data['description'] ?? ''),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Chip(
                                  label: Text('Qtd: $quantity'),
                                  backgroundColor: isLowStock
                                      ? Colors.orange[100]
                                      : Colors.green[100],
                                ),
                                const SizedBox(width: 8),
                                if (data['isConsumable'] ?? false)
                                  const Chip(
                                    label: Text('Consumível'),
                                    backgroundColor: Colors.purple,
                                    labelStyle: TextStyle(color: Colors.white),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: quantity > 0
                                  ? () => _updateQuantity(
                                        accessory.id,
                                        quantity - 1,
                                      )
                                  : null,
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () => _updateQuantity(
                                accessory.id,
                                quantity + 1,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _confirmDelete(accessory.id),
                            ),
                          ],
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

  void _confirmDelete(String accessoryId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text(
          'Tem certeza que deseja excluir este acessório?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAccessory(accessoryId);
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}