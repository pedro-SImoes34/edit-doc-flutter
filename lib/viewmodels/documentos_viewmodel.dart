import 'package:flutter/foundation.dart';
import '../models/documento.dart';
import '../models/services/documento_storage_service.dart';

class DocumentosViewModel extends ChangeNotifier {
  final DocumentoStorageService _storage = DocumentoStorageService();

  List<Documento> _documentos = [];
  bool _carregando = false;

  List<Documento> get documentos => List.unmodifiable(_documentos);
  bool get carregando => _carregando;

  Future<List<Documento>> _lerOrdenado() async {
    final lista = await _storage.listar();
    lista.sort((a, b) => b.atualizadoEm.compareTo(a.atualizadoEm));
    return lista;
  }

  Future<void> carregar() async {
    _carregando = true;
    notifyListeners();
    _documentos = await _lerOrdenado();
    _carregando = false;
    notifyListeners();
  }

  Future<void> criar({required String titulo, required String conteudo}) async {
    final documento = Documento(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      titulo: titulo.trim(),
      conteudo: conteudo,
      atualizadoEm: DateTime.now(),
    );
    await _storage.criar(documento);
    _documentos = await _lerOrdenado();
    notifyListeners();
  }

  Future<void> atualizar(
    Documento original, {
    required String titulo,
    required String conteudo,
  }) async {
    final atualizado = original.copyWith(
      titulo: titulo.trim(),
      conteudo: conteudo,
      atualizadoEm: DateTime.now(),
    );
    await _storage.atualizar(atualizado);
    _documentos = await _lerOrdenado();
    notifyListeners();
  }

  Future<void> excluir(String id) async {
    await _storage.excluir(id);
    _documentos = await _lerOrdenado();
    notifyListeners();
  }
}