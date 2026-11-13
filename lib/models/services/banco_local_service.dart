import '../usuario.dart';

class BancoLocalService {
  static final List<Usuario> _tabelaUsuarios = [
    Usuario(nome: 'Professor', email: 'prof@email.com', senha: '123456'),
  ];

  static Future<bool> cadastrarUsuario(Usuario novoUsuario) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final jaExiste = _tabelaUsuarios.any((u) => u.email == novoUsuario.email);
    if (jaExiste) return false;
    _tabelaUsuarios.add(novoUsuario);
    return true;
  }

  static Future<Usuario?> autenticar(String email, String senha) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _tabelaUsuarios.firstWhere(
        (u) => u.email == email && u.senha == senha,
      );
    } catch (e) {
      return null;
    }
  }

  static Future<List<Usuario>> obterTodosUsuarios() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_tabelaUsuarios);
  }
}