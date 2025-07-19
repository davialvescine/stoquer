import 'package:flutter/material.dart';
import 'package:stoquer/models/ativo.dart';
import 'package:stoquer/services/ativo_service.dart';
import 'package:uuid/uuid.dart';

class AtivoFormScreen extends StatefulWidget {
  final Ativo? ativo; // Se 'ativo' não for nulo, estamos editando. Se for nulo, estamos criando.

  const AtivoFormScreen({super.key, this.ativo});

  @override
  State<AtivoFormScreen> createState() => _AtivoFormScreenState();
}

class _AtivoFormScreenState extends State<AtivoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ativoService = AtivoService();
  bool _isLoading = false;

  // Controladores para cada campo do formulário
  late TextEditingController _nomeController;
  late TextEditingController _codigoController;
  late TextEditingController _categoriaController;
  late TextEditingController _descricaoController;
  
  // ... adicione controladores para outros campos conforme necessário

  @override
  void initState() {
    super.initState();
    // Preenche os campos se estivermos no modo de edição
    _nomeController = TextEditingController(text: widget.ativo?.nome ?? '');
    _codigoController = TextEditingController(text: widget.ativo?.codigo ?? '');
    _categoriaController = TextEditingController(text: widget.ativo?.categoria ?? '');
    _descricaoController = TextEditingController(text: widget.ativo?.descricao ?? '');
  }

  @override
  void dispose() {
    // Limpa os controladores
    _nomeController.dispose();
    _codigoController.dispose();
    _categoriaController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _salvarAtivo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() { _isLoading = true; });

    try {
      if (widget.ativo == null) {
        // --- Modo de Criação ---
        final novoAtivo = Ativo(
          id: const Uuid().v4(), // Gera um ID único localmente (Firestore vai gerar o dele)
          nome: _nomeController.text,
          codigo: _codigoController.text,
          categoria: _categoriaController.text,
          descricao: _descricaoController.text,
          disponivel: true,
          dataCadastro: DateTime.now(),
        );
        await _ativoService.criarAtivo(novoAtivo);
      } else {
        // --- Modo de Edição ---
        final ativoAtualizado = Ativo(
          id: widget.ativo!.id, // Usa o ID existente
          nome: _nomeController.text,
          codigo: _codigoController.text,
          categoria: _categoriaController.text,
          descricao: _descricaoController.text,
          // Mantém os outros dados do ativo original
          disponivel: widget.ativo!.disponivel,
          dataCadastro: widget.ativo!.dataCadastro,
          condicao: widget.ativo!.condicao,
          emprestimoAtualId: widget.ativo!.emprestimoAtualId,
          localizacao: widget.ativo!.localizacao,
          numeroSerie: widget.ativo!.numeroSerie,
          valorEstimado: widget.ativo!.valorEstimado,
        );
        await _ativoService.atualizarAtivo(ativoAtualizado);
      }
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ativo salvo com sucesso!'), backgroundColor: Colors.green));
      Navigator.of(context).pop();

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao salvar ativo: $e'), backgroundColor: Colors.red));
    } finally {
      if(mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determina se estamos editando para mudar o título da tela
    final isEditing = widget.ativo != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Ativo' : 'Novo Ativo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome do Ativo'),
                validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _codigoController,
                decoration: const InputDecoration(labelText: 'Código'),
                validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoriaController,
                decoration: const InputDecoration(labelText: 'Categoria'),
                validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _salvarAtivo,
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}