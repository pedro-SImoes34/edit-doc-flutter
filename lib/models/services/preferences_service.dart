import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const _chaveTema = 'tema';
  static const _chaveNotificacoes = 'notificacoes';
  static const _chaveSessaoNome = 'sessao_nome';
  static const _chaveSessaoEmail = 'sessao_email';

  Future<String> obterTema() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_chaveTema) ?? 'Claro';
  }

  Future<void> salvarTema(String tema) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chaveTema, tema);
  }

  Future<bool> obterNotificacoes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_chaveNotificacoes) ?? true;
  }

  Future<void> salvarNotificacoes(bool valor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_chaveNotificacoes, valor);
  }

  Future<void> salvarSessao(String nome, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chaveSessaoNome, nome);
    await prefs.setString(_chaveSessaoEmail, email);
  }

  /// Retorna null se não houver sessão salva.
  Future<Map<String, String>?> obterSessao() async {
    final prefs = await SharedPreferences.getInstance();
    final nome = prefs.getString(_chaveSessaoNome);
    final email = prefs.getString(_chaveSessaoEmail);
    if (nome == null || email == null) return null;
    return {'nome': nome, 'email': email};
  }

  Future<void> limparSessao() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chaveSessaoNome);
    await prefs.remove(_chaveSessaoEmail);
  }
}