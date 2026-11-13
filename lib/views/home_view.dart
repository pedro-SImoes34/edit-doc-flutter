import 'package:flutter/material.dart';
import '../viewmodels/auth_viewmodel.dart';

class HomeView extends StatelessWidget {
  final AuthViewModel viewModel;
  const HomeView({super.key, required this.viewModel});

  Future<void> _mostrarPreferencias(BuildContext context) async {
    await viewModel.carregarPreferencias();
    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Preferências do Usuário'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tema: ${viewModel.temaSalvo}'),
            const SizedBox(height: 8),
            Text('Notificações: ${viewModel.notificacoesSalvas}'),
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

  Future<void> _mostrarUsuarios(BuildContext context) async {
    await viewModel.carregarUsuarios();
    if (!context.mounted) return;

    final usuarios = viewModel.usuarios;
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

  Widget _criarCard(
    IconData icone,
    String titulo,
    Color cor,
    VoidCallback aoClicar,
  ) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: aoClicar,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icone, size: 48, color: cor),
            const SizedBox(height: 12),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nomeUsuario = viewModel.usuarioLogado?.nome ?? 'Usuário';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tela Principal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              viewModel.logout();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.account_circle,
                    size: 56,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Olá, $nomeUsuario!',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'O que você quer ver hoje?',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Menu',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _criarCard(
                    Icons.settings,
                    'Preferências do Usuário',
                    Colors.orange,
                    () => _mostrarPreferencias(context),
                  ),
                  _criarCard(
                    Icons.group,
                    'Usuários no Banco Local',
                    Colors.green,
                    () => _mostrarUsuarios(context),
                  ),
                ],
              ),
            ),
          ],
        ),
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