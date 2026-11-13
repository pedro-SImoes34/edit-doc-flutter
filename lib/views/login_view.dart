import 'package:flutter/material.dart';
import '../utils/validadores.dart';
import '../viewmodels/auth_viewmodel.dart';

class LoginView extends StatefulWidget {
  final AuthViewModel viewModel;
  const LoginView({super.key, required this.viewModel});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  Future<void> _fazerLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final sucesso = await widget.viewModel.login(
      _emailController.text,
      _senhaController.text,
    );

    if (!mounted) return;
    if (!sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('E-mail ou senha incorretos')),
      );
      return;
    }
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
              ElevatedButton(
                onPressed: _fazerLogin,
                child: const Text('Entrar'),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/cadastro'),
                child: const Text('Não tem uma conta? Cadastre-se'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}