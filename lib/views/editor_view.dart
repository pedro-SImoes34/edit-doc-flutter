import 'package:flutter/material.dart';
import '../models/documento.dart';
import '../utils/validadores.dart';
import '../viewmodels/documentos_viewmodel.dart';

class EditorView extends StatefulWidget {
  final DocumentosViewModel viewModel;
  const EditorView({super.key, required this.viewModel});

  @override
  State<EditorView> createState() => _EditorViewState();
}

class _EditorViewState extends State<EditorView> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _conteudoController = TextEditingController();

  Documento? _documento; // null = criando um documento novo
  bool _iniciado = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_iniciado) return;
    _iniciado = true;

    _documento = ModalRoute.of(context)?.settings.arguments as Documento?;
    if (_documento != null) {
      _tituloController.text = _documento!.titulo;
      _conteudoController.text = _documento!.conteudo;
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_documento == null) {
      await widget.viewModel.criar(
        titulo: _tituloController.text,
        conteudo: _conteudoController.text,
      );
    } else {
      await widget.viewModel.atualizar(
        _documento!,
        titulo: _tituloController.text,
        conteudo: _conteudoController.text,
      );
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _conteudoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editando = _documento != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(editando ? 'Editar Documento' : 'Novo Documento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
                validator: validarTitulo,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: TextFormField(
                  controller: _conteudoController,
                  decoration: const InputDecoration(
                    labelText: 'Conteúdo',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _salvar,
                  child: Text(editando ? 'Salvar alterações' : 'Criar documento'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}