import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/item_model.dart';
import '../../services/firestore_service.dart';
import '../../services/storage_service.dart';

class AddEditItemScreen extends StatefulWidget {
  final Item? item;

  const AddEditItemScreen({super.key, this.item});

  @override
  State<AddEditItemScreen> createState() => _AddEditItemScreenState();
}

class _AddEditItemScreenState extends State<AddEditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _firestore = FirestoreService();
  final _storage = StorageService();
  final _picker = ImagePicker();

  String? _categoryId;
  File? _imageFile;
  File? _invoiceFile;
  bool _loading = false;
  List<Map<String, dynamic>> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
    if (widget.item != null) {
      _nameController.text = widget.item!.name;
      _quantityController.text = widget.item!.quantity.toString();
      _categoryId = widget.item!.categoryId;
    } else {
      _quantityController.text = '1'; // Valor padrão para novos itens
    }
  }

  Future<void> _loadCategories() async {
    _firestore.getCategories().listen((cats) {
      setState(() => _categories = cats.map((cat) => {'id': cat.id, 'nome': cat.name}).toList());
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() => _imageFile = File(picked.path));
      }
    } catch (e) {
      _showError('Erro ao selecionar imagem');
    }
  }

  Future<void> _pickInvoice() async {
    try {
      final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        setState(() => _invoiceFile = File(picked.path));
      }
    } catch (e) {
      _showError('Erro ao selecionar nota fiscal');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _loading = true);

    try {
      // Upload files if needed
      if (_imageFile != null) {
        await _storage.uploadImage(_imageFile!);
      }
      if (_invoiceFile != null) {
        await _storage.uploadImage(_invoiceFile!);
      }

      final item = Item(
        id: widget.item?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        invoiceId: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        categoryId: _categoryId!,
        quantity: double.parse(_quantityController.text),
        unitPrice: 0.0,
        total: 0.0,
        description: 'Item criado via app',
      );

      if (widget.item != null) {
        await _firestore.updateItem(item);
      } else {
        await _firestore.addItem(item);
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      _showError('Erro ao salvar item: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item != null ? 'Editar Item' : 'Novo Item'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => _pickImage(ImageSource.camera),
                          child: Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: _imageFile != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      _imageFile!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : widget.item?.description != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: const Icon(
                                          Icons.image,
                                          size: 50,
                                          color: Colors.grey,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.camera_alt,
                                        size: 50,
                                        color: Colors.grey,
                                      ),
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: IconButton(
                            icon: const Icon(Icons.photo_library),
                            onPressed: () => _pickImage(ImageSource.gallery),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.all(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nome do Item',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v?.isEmpty ?? true ? 'Nome obrigatório' : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _quantityController,
                      decoration: const InputDecoration(
                        labelText: 'Quantidade',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Quantidade obrigatória';
                        if (int.tryParse(v) == null) return 'Digite um número válido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      value: _categoryId,
                      decoration: const InputDecoration(
                        labelText: 'Categoria',
                        border: OutlineInputBorder(),
                      ),
                      items: _categories.map((cat) {
                        return DropdownMenuItem<String>(
                          value: cat['id'] as String,
                          child: Text(cat['nome'] as String),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _categoryId = value),
                      validator: (v) => v == null ? 'Selecione uma categoria' : null,
                    ),
                    const SizedBox(height: 16),

                    OutlinedButton.icon(
                      onPressed: _pickInvoice,
                      icon: const Icon(Icons.attach_file),
                      label: Text(_invoiceFile != null 
                          ? 'Nota fiscal selecionada'
                          : 'Anexar nota fiscal'),
                    ),
                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: _saveItem,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        widget.item != null ? 'Atualizar Item' : 'Salvar Item',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }
}