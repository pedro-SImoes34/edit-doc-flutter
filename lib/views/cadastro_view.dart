import 'package:flutter/material.dart';
import '../utils/validadores.dart';
import '../viewmodels/auth_viewmodel.dart';

class CadastroView extends StatefulWidget {
  final AuthViewModel viewModel;
  const CadastroView({super.key, required this.viewModel});

  @override
  State<CadastroView> createState() => _CadastroViewState();
}

class _CadastroViewState extends State<CadastroView> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  Future<void> _cadastrar() async {
    if (!_formKey.currentState!.validate()) return;

    final cadastrou = await widget.viewModel.cadastrar(
      nome: _nomeController.text,
      email: _emailController.text,
      senha: _senhaController.text,
    );

    if (!mounted) return;
    if (!cadastrou) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este e-mail já está cadastrado!')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Usuário cadastrado com sucesso!')),
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel;

    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro de Usuário')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome Completo',
                  border: OutlineInputBorder(),
                ),
                validator: validarNome,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: validarEmail,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _senhaController,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: validarSenha,
              ),
              const SizedBox(height: 24),
              const Text(
                'Tema do App',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              ListenableBuilder(
                listenable: vm,
                builder: (context, _) {
                  return Column(
                    children: [
                      RadioGroup<String>(
                        groupValue: vm.tema,
                        onChanged: (valor) {
                          if (valor != null) vm.alterarTema(valor);
                        },
                        child: const Column(
                          children: [
                            RadioListTile<String>(
                              title: Text('Tema Claro'),
                              value: 'Claro',
                            ),
                            RadioListTile<String>(
                              title: Text('Tema Escuro'),
                              value: 'Escuro',
                            ),
                          ],
                        ),
                      ),
                      SwitchListTile(
                        title: const Text('Notificações ativadas'),
                        value: vm.notificacoes,
                        onChanged: vm.alterarNotificacoes,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _cadastrar,
                child: const Text('Cadastrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}