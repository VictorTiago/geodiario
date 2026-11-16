import 'package:flutter_test/flutter_test.dart';
import 'package:geodiario/models/registro.dart';

void main() {
  group('Registro', () {
    final registro = Registro(
      id: 7,
      titulo: 'Praça da Liberdade',
      descricao: 'Fim de tarde',
      caminhoFoto: '/data/fotos/geo_1.jpg',
      dataHora: DateTime(2026, 11, 15, 17, 30, 12),
      latitude: -19.932100,
      longitude: -43.938000,
    );

    test('toMap usa os nomes de coluna da tabela SQLite', () {
      final map = registro.toMap();
      expect(map.keys, containsAll(<String>[
        'id', 'titulo', 'descricao', 'caminho_foto',
        'data_hora', 'latitude', 'longitude',
      ]));
      expect(map['data_hora'], '2026-11-15T17:30:12.000');
    });

    test('fromMap(toMap()) preserva todos os campos', () {
      final copia = Registro.fromMap(registro.toMap());
      expect(copia.id, registro.id);
      expect(copia.titulo, registro.titulo);
      expect(copia.descricao, registro.descricao);
      expect(copia.caminhoFoto, registro.caminhoFoto);
      expect(copia.dataHora, registro.dataHora);
      expect(copia.latitude, registro.latitude);
      expect(copia.longitude, registro.longitude);
    });

    test('toMap omite o id quando o registro ainda não foi salvo', () {
      final novo = Registro(
        titulo: 't', descricao: '', caminhoFoto: 'x',
        dataHora: DateTime(2026), latitude: 0, longitude: 0,
      );
      expect(novo.toMap().containsKey('id'), isFalse);
    });
  });
}
