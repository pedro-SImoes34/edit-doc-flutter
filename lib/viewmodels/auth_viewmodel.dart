import 'package:flutter/foundation.dart';
import '../models/usuario.dart';
import '../models/services/banco_local_service.dart';
import '../models/services/preferences_service.dart';

class AuthViewModel extends ChangeNotifier {
  final PreferencesService _prefs = PreferencesService();

  String? _nomeUsuario;
  String? _emailUsuario;
  String _tema = 'Claro';
  bool _notificacoes = true;
  List<Usuario> _usuarios = [];

  String? get nomeUsuario => _nomeUsuario;
  String? get emailUsuario => _emailUsuario;
  bool get logado => _emailUsuario != null;
  String get tema => _tema;
  bool get notificacoes => _notificacoes;
  List<Usuario> get usuarios => _usuarios;

  /// Chamado no main() antes do runApp: restaura tema, notificações e sessão.
  Future<void> inicializar() async {
    _tema = await _prefs.obterTema();
    _notificacoes = await _prefs.obterNotificacoes();
    final sessao = await _prefs.obterSessao();
    if (sessao != null) {
      _nomeUsuario = sessao['nome'];
      _emailUsuario = sessao['email'];
    }
    notifyListeners();
  }

  // ---------- Autenticação ----------

  Future<bool> login(String email, String senha) async {
    final usuario = await BancoLocalService.autenticar(
      email.trim().toLowerCase(),
      senha,
    );
    if (usuario == null) return false;

    _nomeUsuario = usuario.nome;
    _emailUsuario = usuario.email;
    await _prefs.salvarSessao(usuario.nome, usuario.email);
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _nomeUsuario = null;
    _emailUsuario = null;
    await _prefs.limparSessao();
    notifyListeners();
  }

  // ---------- Preferências ----------

  Future<void> alterarTema(String novoTema) async {
    _tema = novoTema;
    notifyListeners();
    await _prefs.salvarTema(novoTema);
  }

  Future<void> alterarNotificacoes(bool valor) async {
    _notificacoes = valor;
    notifyListeners();
    await _prefs.salvarNotificacoes(valor);
  }

  // ---------- Cadastro ----------

  /// Retorna false se o e-mail já estiver cadastrado.
  Future<bool> cadastrar({
    required String nome,
    required String email,
    required String senha,
  }) {
    final novoUsuario = Usuario(
      nome: nome.trim(),
      email: email.trim().toLowerCase(),
      senha: senha,
    );
    return BancoLocalService.cadastrarUsuario(novoUsuario);
  }

  // ---------- Lista de usuários ----------

  Future<void> carregarUsuarios() async {
    _usuarios = await BancoLocalService.obterTodosUsuarios();
    notifyListeners();
  }
}