import 'package:flutter/material.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/documentos_viewmodel.dart';
import 'views/login_view.dart';
import 'views/cadastro_view.dart';
import 'views/home_view.dart';
import 'views/editor_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authViewModel = AuthViewModel();
  await authViewModel.inicializar();

  runApp(MeuApp(authViewModel: authViewModel));
}

class MeuApp extends StatelessWidget {
  final AuthViewModel authViewModel;
  final DocumentosViewModel documentosViewModel = DocumentosViewModel();

  MeuApp({super.key, required this.authViewModel});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: authViewModel,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Edit Doc',
          theme: ThemeData(
            colorSchemeSeed: Colors.blue,
            brightness: Brightness.light,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorSchemeSeed: Colors.blue,
            brightness: Brightness.dark,
            useMaterial3: true,
          ),
          themeMode:
              authViewModel.tema == 'Escuro' ? ThemeMode.dark : ThemeMode.light,
          initialRoute: authViewModel.logado ? '/home' : '/',
          routes: {
            '/': (context) => LoginView(viewModel: authViewModel),
            '/cadastro': (context) => CadastroView(viewModel: authViewModel),
            '/home': (context) => HomeView(
                  authViewModel: authViewModel,
                  documentosViewModel: documentosViewModel,
                ),
            '/editor': (context) => EditorView(viewModel: documentosViewModel),
          },
        );
      },
    );
  }
}