import 'package:flutter/foundation.dart';
import '../models/usuario.dart';
import '../models/services/banco_local_service.dart';
import '../models/services/preferences_service.dart';

class AuthViewModel extends ChangeNotifier {
  Usuario? _usuarioLogado;

  String _tema = 'Claro';
  bool _notificacoes = true;

  String _temaSalvo = 'Não definido';
  String _notificacoesSalvas = 'Não definido';
  List<Usuario> _usuarios = [];

  Usuario? get usuarioLogado => _usuarioLogado;
  String get tema => _tema;
  bool get notificacoes => _notificacoes;
  String get temaSalvo => _temaSalvo;
  String get notificacoesSalvas => _notificacoesSalvas;
  List<Usuario> get usuarios => _usuarios;

  Future<bool> login(String email, String senha) async {
    final usuario = await BancoLocalService.autenticar(
      email.trim().toLowerCase(),
      senha,
    );
    if (usuario == null) return false;
    _usuarioLogado = usuario;
    notifyListeners();
    return true;
  }

  void logout() {
    _usuarioLogado = null;
    notifyListeners();
  }

  void alterarTema(String novoTema) {
    _tema = novoTema;
    notifyListeners();
  }

  void alterarNotificacoes(bool valor) {
    _notificacoes = valor;
    notifyListeners();
  }

  Future<bool> cadastrar({
    required String nome,
    required String email,
    required String senha,
  }) async {
    final novoUsuario = Usuario(
      nome: nome.trim(),
      email: email.trim().toLowerCase(),
      senha: senha,
    );

    final cadastrou = await BancoLocalService.cadastrarUsuario(novoUsuario);
    if (!cadastrou) return false;

    final prefs = await PreferencesService.getInstance();
    await prefs.setString('tema', _tema);
    await prefs.setBool('notificacoes', _notificacoes);

    _tema = 'Claro';
    _notificacoes = true;
    notifyListeners();
    return true;
  }

  Future<void> carregarPreferencias() async {
    final prefs = await PreferencesService.getInstance();
    _temaSalvo = prefs.getString('tema') ?? 'Não definido';

    final notif = prefs.getBool('notificacoes');
    _notificacoesSalvas = 'Não definido';
    if (notif != null) {
      _notificacoesSalvas = notif ? 'Ativadas' : 'Desativadas';
    }
    notifyListeners();
  }

  Future<void> carregarUsuarios() async {
    _usuarios = await BancoLocalService.obterTodosUsuarios();
    notifyListeners();
  }
}