import 'package:flutter/material.dart';
import '../models/documento.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/documentos_viewmodel.dart';

class HomeView extends StatefulWidget {
  final AuthViewModel authViewModel;
  final DocumentosViewModel documentosViewModel;

  const HomeView({
    super.key,
    required this.authViewModel,
    required this.documentosViewModel,
  });

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  AuthViewModel get _auth => widget.authViewModel;
  DocumentosViewModel get _docs => widget.documentosViewModel;

  @override
  void initState() {
    super.initState();
    _docs.carregar();
  }

  String _formatarData(DateTime d) {
    String dois(int n) => n.toString().padLeft(2, '0');
    return '${dois(d.day)}/${dois(d.month)}/${d.year} ${dois(d.hour)}:${dois(d.minute)}';
  }

  void _mostrarPreferencias() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Preferências do Usuário'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tema: ${_auth.tema}'),
            const SizedBox(height: 8),
            Text(
              'Notificações: ${_auth.notificacoes ? 'Ativadas' : 'Desativadas'}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Future<void> _mostrarUsuarios() async {
    await _auth.carregarUsuarios();
    if (!mounted) return;

    final usuarios = _auth.usuarios;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Usuários no Banco Local'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: usuarios.length,
            itemBuilder: (context, index) {
              final usuario = usuarios[index];
              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(usuario.nome),
                subtitle: Text(usuario.email),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmarExclusao(Documento doc) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir documento'),
        content: Text('Deseja excluir "${doc.titulo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmou == true) {
      await _docs.excluir(doc.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Documentos'),
        actions: [
          ListenableBuilder(
            listenable: _auth,
            builder: (context, _) => IconButton(
              tooltip: 'Alternar tema',
              icon: Icon(
                _auth.tema == 'Escuro' ? Icons.light_mode : Icons.dark_mode,
              ),
              onPressed: () => _auth.alterarTema(
                _auth.tema == 'Escuro' ? 'Claro' : 'Escuro',
              ),
            ),
          ),
          IconButton(
            tooltip: 'Preferências',
            icon: const Icon(Icons.settings),
            onPressed: _mostrarPreferencias,
          ),
          IconButton(
            tooltip: 'Usuários',
            icon: const Icon(Icons.group),
            onPressed: _mostrarUsuarios,
          ),
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout),
            onPressed: () {
              _auth.logout();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Text(
              'Olá, ${_auth.nomeUsuario ?? 'Usuário'}!',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(
            child: ListenableBuilder(
              listenable: _docs,
              builder: (context, _) {
                if (_docs.carregando) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (_docs.documentos.isEmpty) {
                  return const Center(
                    child: Text('Nenhum documento ainda. Toque em + para criar.'),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _docs.documentos.length,
                  itemBuilder: (context, index) {
                    final doc = _docs.documentos[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.description),
                        title: Text(doc.titulo),
                        subtitle: Text(
                          '${doc.conteudo.isEmpty ? '(sem conteúdo)' : doc.conteudo}\n'
                          '${_formatarData(doc.atualizadoEm)}',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        isThreeLine: true,
                        trailing: IconButton(
                          tooltip: 'Excluir',
                          icon: const Icon(Icons.delete),
                          onPressed: () => _confirmarExclusao(doc),
                        ),
                        onTap: () =>
                            Navigator.pushNamed(context, '/editor', arguments: doc),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Novo documento',
        onPressed: () => Navigator.pushNamed(context, '/editor'),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: Container(
        height: 50,
        color: Colors.blue,
        alignment: Alignment.center,
        child: const Text(
          'Desenvolvido por: Pedro Simões',
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
    );
  }
}