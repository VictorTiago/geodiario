/// Modelo de dados de um registro do GeoDiário.
///
/// Cada registro representa uma fotografia associada à data/hora da captura,
/// às coordenadas GPS e a um título/descrição informados pelo usuário.
class Registro {
  final int? id; // Gerado pelo SQLite (AUTOINCREMENT); nulo antes de inserir.
  final String titulo;
  final String descricao;
  final String caminhoFoto; // Caminho do arquivo da foto no armazenamento local.
  final DateTime dataHora;
  final double latitude;
  final double longitude;

  const Registro({
    this.id,
    required this.titulo,
    required this.descricao,
    required this.caminhoFoto,
    required this.dataHora,
    required this.latitude,
    required this.longitude,
  });

  /// Converte um Map (linha da tabela SQLite) em objeto Registro.
  factory Registro.fromMap(Map<String, dynamic> map) {
    return Registro(
      id: map['id'] as int?,
      titulo: map['titulo'] as String,
      descricao: (map['descricao'] as String?) ?? '',
      caminhoFoto: map['caminho_foto'] as String,
      dataHora: DateTime.parse(map['data_hora'] as String),
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
    );
  }

  /// Converte o objeto em Map para gravação no SQLite.
  /// A data/hora é salva como texto no formato ISO 8601.
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'caminho_foto': caminhoFoto,
      'data_hora': dataHora.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  Registro copyWith({int? id}) {
    return Registro(
      id: id ?? this.id,
      titulo: titulo,
      descricao: descricao,
      caminhoFoto: caminhoFoto,
      dataHora: dataHora,
      latitude: latitude,
      longitude: longitude,
    );
  }
}
