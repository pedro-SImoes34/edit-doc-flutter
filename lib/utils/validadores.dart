String? validarNome(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Informe seu nome completo';
  }
  return null;
}

String? validarEmail(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Informe seu e-mail';
  }
  final email = value.trim().toLowerCase();
  if (!email.contains('@')) {
    return 'O e-mail precisa ter o caractere @';
  }
  final partes = email.split('@');
  if (partes.length != 2 || partes[0].isEmpty || partes[1].isEmpty) {
    return 'Informe um e-mail válido';
  }
  final dominio = partes[1];
  final terminaCom = dominio.endsWith('.com') && dominio.length > 4;
  final terminaComBr = dominio.endsWith('.com.br') && dominio.length > 7;
  if (!terminaCom && !terminaComBr) {
    return 'O e-mail deve terminar com .com ou .com.br';
  }
  return null;
}

String? validarSenha(String? value) {
  if (value == null || value.length < 6) {
    return 'A senha deve ter pelo menos 6 caracteres';
  }
  return null;
}