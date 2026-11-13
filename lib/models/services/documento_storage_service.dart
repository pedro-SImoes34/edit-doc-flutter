import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../documento.dart';

class DocumentoStorageService {
  static const _chave = 'documentos';

  // READ
  Future<List<Documento>> listar() async {
    final prefs = await SharedPreferences.getInstance();
    final texto = prefs.getString(_chave);
    if (texto == null) return [];

    try {
      final lista = jsonDecode(texto) as List<dynamic>;
      return lista
          .map((e) => Documento.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // JSON corrompido: começa com a lista vazia
      return [];
    }
  }

  Future<void> _salvarTodos(List<Documento> documentos) async {
    final prefs = await SharedPreferences.getInstance();
    final texto = jsonEncode(documentos.map((d) => d.toJson()).toList());
    await prefs.setString(_chave, texto);
  }

  // CREATE
  Future<void> criar(Documento documento) async {
    final documentos = await listar();
    documentos.add(documento);
    await _salvarTodos(documentos);
  }

  // UPDATE
  Future<void> atualizar(Documento documento) async {
    final documentos = await listar();
    final indice = documentos.indexWhere((d) => d.id == documento.id);
    if (indice == -1) return;
    documentos[indice] = documento;
    await _salvarTodos(documentos);
  }

  // DELETE
  Future<void> excluir(String id) async {
    final documentos = await listar();
    documentos.removeWhere((d) => d.id == id);
    await _salvarTodos(documentos);
  }
}