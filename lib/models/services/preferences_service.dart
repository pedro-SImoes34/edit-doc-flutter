class PreferencesService {
  static final PreferencesService _instancia = PreferencesService._interno();
  final Map<String, dynamic> _dados = {};

  PreferencesService._interno();

  static Future<PreferencesService> getInstance() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _instancia;
  }

  Future<bool> setString(String chave, String valor) async {
    _dados[chave] = valor;
    return true;
  }

  Future<bool> setBool(String chave, bool valor) async {
    _dados[chave] = valor;
    return true;
  }

  String? getString(String chave) => _dados[chave] as String?;
  bool? getBool(String chave) => _dados[chave] as bool?;
}