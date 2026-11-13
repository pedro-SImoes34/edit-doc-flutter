# Edit Doc Flutter: Relatório de Migração Arquitetural (MVVM)

## 1. Introdução

Este repositório contém um aplicativo Flutter com três telas (Login, Cadastro e Home). Nesta fase, o código foi reorganizado segundo o padrão arquitetural **MVVM (Model-View-ViewModel)**, com o objetivo de separar as responsabilidades da aplicação em camadas.

## 2. Mapeamento de Classes e Widgets

A tabela a seguir relaciona cada elemento do código original feito no DartPad com sua nova localização.

| Elemento no DartPad | Tipo | Novo arquivo | Novo nome (se alterado) |
|---|---|---|---|
| `main()` | Função | `lib/main.dart` | (mantido) |
| `MeuApp` | Widget (`StatelessWidget`) | `lib/main.dart` | (mantido) |
| `validarNome()` | Função auxiliar | `lib/utils/validadores.dart` | (mantido) |
| `validarEmail()` | Função auxiliar | `lib/utils/validadores.dart` | (mantido) |
| `validarSenha()` | Função auxiliar | `lib/utils/validadores.dart` | (mantido) |
| `TelaLogin` e `_TelaLoginState` | Tela (`StatefulWidget`) | `lib/views/login_view.dart` | `LoginView` e `_LoginViewState` |
| `TelaCadastro` e `_TelaCadastroState` | Tela (`StatefulWidget`) | `lib/views/cadastro_view.dart` | `CadastroView` e `_CadastroViewState` |
| `TelaHome` | Tela (`StatelessWidget`) | `lib/views/home_view.dart` | `HomeView` |
| `Usuario` | Modelo (entidade) | `lib/models/usuario.dart` | (mantido) |
| `BancoDadosLocal` | Serviço de dados | `lib/models/services/banco_local_service.dart` | `BancoLocalService` |
| `SharedPreferences` (simulada) | Serviço de dados | `lib/models/services/preferences_service.dart` | `PreferencesService` |
| (não existia) | ViewModel | `lib/viewmodels/auth_viewmodel.dart` | `AuthViewModel` |

## 3. Alterações de Estrutura e Imports

Ao dividir o arquivo único em vários arquivos, foram necessárias as adaptações descritas a seguir.

### 3.1 Organização dos imports

- Cada arquivo passou a importar apenas o que utiliza. Os arquivos de interface importam `package:flutter/material.dart`, enquanto os arquivos de modelo e serviço não dependem do Flutter.
- Os ViewModels importam `package:flutter/foundation.dart`, que fornece o `ChangeNotifier` sem carregar a biblioteca de widgets.
- Foram utilizados **imports relativos** (por exemplo, `../utils/validadores.dart`), o que evita depender do nome do pacote definido no `pubspec.yaml`.
- Foi respeitado a direção das dependências do MVVM: a **View** conhece o **ViewModel**, o **ViewModel** conhece os **Models**, e os Models não conhecem nenhuma das camadas acima. Por exemplo, `banco_local_service.dart` importa apenas `../usuario.dart`.

### 3.2 Construtores

- As views passaram a receber o ViewModel por **injeção via construtor**, com um parâmetro nomeado obrigatório:

  ```dart
  class LoginView extends StatefulWidget {
    final AuthViewModel viewModel;
    const LoginView({super.key, required this.viewModel});
    ...
  }
  ```

- Dentro de uma classe `State`, o ViewModel é acessado por `widget.viewModel`. Na `HomeView`, que é um `StatelessWidget`, o acesso é direto por `viewModel`.
- A classe `MeuApp` deixou de ser `const`, pois agora possui um atributo de instância (`_authViewModel`). Por consequência, `runApp(MeuApp())` e as rotas passaram a ser declaradas sem `const`.
- O `PreferencesService` mantém o padrão **Singleton**, com construtor privado (`PreferencesService._interno()`) e acesso por `getInstance()`, de modo que os dados sejam compartilhados entre todas as telas.

### 3.3 Visibilidade de atributos

No Dart, o prefixo `_` torna um membro privado à **biblioteca** (ou seja, ao arquivo), e não à classe. No DartPad, como tudo estava no mesmo arquivo, esse isolamento não era efetivo. Após a separação:

- A lista `_tabelaUsuarios` ficou realmente encapsulada em `BancoLocalService`. O acesso externo só ocorre pelos métodos públicos `cadastrarUsuario`, `autenticar` e `obterTodosUsuarios`.
- Os atributos de estado do `AuthViewModel` (`_tema`, `_notificacoes`, `_usuarioLogado` etc.) são privados e expostos por **getters** públicos, o que impede que a View altere o estado diretamente sem passar pelos métodos do ViewModel.
- As classes `_LoginViewState` e `_CadastroViewState` continuam privadas ao seu arquivo.
- `obterTodosUsuarios` retorna `List.unmodifiable`, evitando que a lista interna seja modificada fora do serviço.

### 3.4 Rotas nomeadas

As rotas foram mantidas em `main.dart`, dentro do `MaterialApp`:

| Rota | View |
|---|---|
| `/` (inicial) | `LoginView` |
| `/cadastro` | `CadastroView` |
| `/home` | `HomeView` |

Duas alterações relevantes:

1. **Instância única do ViewModel:** o `MeuApp` cria um único `AuthViewModel` e o repassa às três rotas, garantindo que o estado (por exemplo, o usuário logado) seja compartilhado entre as telas.
2. **Fim do uso de `arguments` na rota `/home`:** antes, o nome do usuário era enviado como argumento (`Navigator.pushReplacementNamed(context, '/home', arguments: usuario.nome)`) e lido com `ModalRoute.of(context)?.settings.arguments`. Agora a Home lê `viewModel.usuarioLogado?.nome`, e a navegação é feita sem argumentos.

## 4. Mudanças no Gerenciamento de Estado

### 4.1 Usos de `setState()` removidos

No código original, o `setState()` aparecia somente na tela de cadastro (`_TelaCadastroState`), em dois pontos:

| Local | Finalidade | Situação atual |
|---|---|---|
| `onChanged` do `RadioGroup` | Atualizar `_tema` | Substituído por `vm.alterarTema(valor)` |
| `onChanged` do `SwitchListTile` | Atualizar `_notificacoes` | Substituído por `vm.alterarNotificacoes` |

A `TelaLogin` e a `TelaHome` originalmente não utilizavam `setState()`. Com a migração, **nenhuma das três views contém `setState()`**.

### 4.2 Variáveis de estado transferidas para o ViewModel

| Variável | Origem (DartPad) | Função no `AuthViewModel` |
|---|---|---|
| `_tema` | `_TelaCadastroState` | Tema escolhido no formulário de cadastro |
| `_notificacoes` | `_TelaCadastroState` | Preferência de notificações no formulário de cadastro |
| `_usuarioLogado` | (não existia; o nome era passado por `arguments`) | Usuário autenticado na sessão |
| `_temaSalvo` | Variável local de `_mostrarPreferencias` | Tema lido das preferências, exibido na Home |
| `_notificacoesSalvas` | Variável local de `_mostrarPreferencias` | Texto das notificações ("Ativadas", "Desativadas" ou "Não definido") |
| `_usuarios` | Variável local de `_mostrarUsuarios` | Lista de usuários exibida na Home |

Também foram transferidas para o ViewModel as regras de negócio que antes ficavam nas telas:

- **`login()`:** normaliza o e-mail (`trim` e `toLowerCase`), consulta o serviço e registra o usuário logado.
- **`logout()`:** limpa o usuário logado.
- **`cadastrar()`:** monta o objeto `Usuario`, verifica duplicidade de e-mail, grava as preferências e reinicia o estado do formulário.
- **`carregarPreferencias()` e `carregarUsuarios()`:** buscam os dados nos serviços e os disponibilizam para a Home.

### 4.3 Como as telas escutam as atualizações

O `AuthViewModel` estende `ChangeNotifier`. Sempre que o estado muda, o ViewModel chama `notifyListeners()`, avisando todos os ouvintes registrados. Isso ocorre em `alterarTema`, `alterarNotificacoes`, `login`, `logout`, `cadastrar`, `carregarPreferencias` e `carregarUsuarios`.

Na `CadastroView`, os componentes que dependem do estado reativo (grupo de opções do tema e interruptor de notificações) foram envolvidos em um `ListenableBuilder`:

```dart
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
          ...
        ),
        SwitchListTile(
          value: vm.notificacoes,
          onChanged: vm.alterarNotificacoes,
          ...
        ),
      ],
    );
  },
),
```

O fluxo de reação é o seguinte:

1. O usuário interage com o `RadioGroup` ou com o `SwitchListTile`.
2. A View chama o método correspondente do ViewModel.
3. O ViewModel atualiza a variável privada e executa `notifyListeners()`.
4. O `ListenableBuilder` detecta a notificação e reconstrói **somente** o trecho envolvido, e não a tela inteira.

## 5. Como executar

```bash
flutter pub get
flutter run -d web-server --web-port=8080 --web-hostname=0.0.0.0
```

Também é possível executar com **F5**, utilizando a configuração definida em `.vscode/launch.json`.

**Credenciais de teste:** `prof@email.com` / `123456`