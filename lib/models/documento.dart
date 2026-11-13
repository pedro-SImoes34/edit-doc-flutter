class Documento {
  final String id;
  final String titulo;
  final String conteudo;
  final DateTime atualizadoEm;

  const Documento({
    required this.id,
    required this.titulo,
    required this.conteudo,
    required this.atualizadoEm,
  });

  Documento copyWith({
    String? titulo,
    String? conteudo,
    DateTime? atualizadoEm,
  }) {
    return Documento(
      id: id,
      titulo: titulo ?? this.titulo,
      conteudo: conteudo ?? this.conteudo,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'titulo': titulo,
        'conteudo': conteudo,
        'atualizadoEm': atualizadoEm.toIso8601String(),
      };

  factory Documento.fromJson(Map<String, dynamic> json) {
    return Documento(
      id: json['id'] as String,
      titulo: json['titulo'] as String,
      conteudo: json['conteudo'] as String,
      atualizadoEm: DateTime.parse(json['atualizadoEm'] as String),
    );
  }
}