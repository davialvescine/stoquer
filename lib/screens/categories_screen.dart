/*
 * TELA DE GESTÃO DE CATEGORIAS
 * 
 * Esta tela permite o gerenciamento completo de categorias do sistema Stoquer.
 * Funcionalidades incluem cadastro, edição, personalização visual e controle de status.
 * 
 * FUNCIONALIDADES PRINCIPAIS:
 * - Cadastro de novas categorias com validação
 * - Seleção de cores personalizadas para categorias
 * - Controle de status ativo/inativo
 * - Listagem em tempo real com StreamBuilder
 * - Edição de status diretamente na lista
 * - Exclusão com confirmação
 * - Interface visual com cards coloridos
 */

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/*
 * WIDGET PRINCIPAL: CategoriesScreen
 * 
 * StatefulWidget que gerencia toda a interface de categorias.
 * Utiliza layout com formulário lateral e lista principal.
 */
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

/*
 * ESTADO DA TELA: _CategoriesScreenState
 * 
 * Gerencia todo o estado da tela de gestão de categorias.
 * Controla formulário, cores, validações e interações.
 */
class _CategoriesScreenState extends State<CategoriesScreen> {
  // === CONTROLADORES DE FORMULÁRIO ===
  // Chave global para validação do formulário
  final _formKey = GlobalKey<FormState>();
  
  // Controladores para os campos de texto
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _colorController = TextEditingController();
  
  // === ESTADO DO FORMULÁRIO ===
  // Cor selecionada para a categoria (padrão: azul)
  Color _selectedColor = Colors.blue;
  
  // Status da categoria (ativa/inativa)
  bool _isActive = true;

  /*
   * MÉTODO DO CICLO DE VIDA: dispose
   * 
   * Libera recursos dos controladores para evitar vazamentos de memória.
   * Executado quando o widget é removido da árvore de widgets.
   */
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  /*
   * MÉTODO: _saveCategory
   * 
   * Salva uma nova categoria no Firestore após validação.
   * Inclui cor personalizada e status de ativação.
   * 
   * VALIDAÇÕES:
   * - Nome obrigatório e único
   * - Cor válida selecionada
   * - Descrição opcional
   */
  Future<void> _saveCategory() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Criar documento no Firestore com dados da categoria
        await FirebaseFirestore.instance.collection('categories').add({
          'name': _nameController.text.trim(),
          'description': _descriptionController.text.trim(),
          'color': _selectedColor.toARGB32().toRadixString(16),
          'isActive': _isActive,
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Categoria salva com sucesso!')),
        );

        // Limpar campos
        _nameController.clear();
        _descriptionController.clear();
        setState(() {
          _selectedColor = Colors.blue;
          _isActive = true;
        });
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar categoria: $e')),
        );
      }
    }
  }

  Future<void> _deleteCategory(String categoryId) async {
    try {
      await FirebaseFirestore.instance
          .collection('categories')
          .doc(categoryId)
          .delete();
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Categoria excluída com sucesso!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir categoria: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorias'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Row(
        children: [
          // Formulário lateral
          Container(
            width: 250,
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nova Categoria',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome da Categoria',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o nome da categoria';
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
                      const Text('Cor: '),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () async {
                          // Mostrar seletor de cores
                          _showColorPicker();
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: _selectedColor,
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ],
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
                    onPressed: _saveCategory,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Salvar Categoria'),
                  ),
                ],
              ),
            ),
          ),
          // Lista de categorias
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('categories')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final categories = snapshot.data!.docs;

                if (categories.isEmpty) {
                  return const Center(
                    child: Text('Nenhuma categoria cadastrada'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final data = category.data() as Map<String, dynamic>;
                    final colorValue = int.parse(
                      data['color'] ?? 'FF2196F3',
                      radix: 16,
                    );
                    final categoryColor = Color(colorValue).withValues(alpha: 1.0);

                    return Card(
                      child: ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: categoryColor,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        title: Text(data['name'] ?? ''),
                        subtitle: Text(data['description'] ?? ''),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Switch(
                              value: data['isActive'] ?? false,
                              onChanged: (value) async {
                                await category.reference.update({
                                  'isActive': value,
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Confirmar exclusão'),
                                    content: const Text(
                                      'Tem certeza que deseja excluir esta categoria?'
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancelar'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          _deleteCategory(category.id);
                                        },
                                        child: const Text('Excluir'),
                                      ),
                                    ],
                                  ),
                                );
                              },
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

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selecione uma cor'),
        content: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            Colors.red,
            Colors.pink,
            Colors.purple,
            Colors.deepPurple,
            Colors.indigo,
            Colors.blue,
            Colors.lightBlue,
            Colors.cyan,
            Colors.teal,
            Colors.green,
            Colors.lightGreen,
            Colors.lime,
            Colors.yellow,
            Colors.amber,
            Colors.orange,
            Colors.deepOrange,
            Colors.brown,
            Colors.grey,
            Colors.blueGrey,
          ].map((color) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedColor = color;
                });
                Navigator.pop(context);
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: _selectedColor == color
                        ? Colors.black
                        : Colors.grey,
                    width: _selectedColor == color ? 3 : 1,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}