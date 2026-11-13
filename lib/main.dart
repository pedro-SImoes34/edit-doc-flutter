import 'package:flutter/material.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'views/login_view.dart';
import 'views/cadastro_view.dart';
import 'views/home_view.dart';

void main() {
  runApp(MeuApp());
}

class MeuApp extends StatelessWidget {
  MeuApp({super.key});

  final AuthViewModel _authViewModel = AuthViewModel();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aula de Roteamento e Form',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginView(viewModel: _authViewModel),
        '/cadastro': (context) => CadastroView(viewModel: _authViewModel),
        '/home': (context) => HomeView(viewModel: _authViewModel),
      },
    );
  }
}