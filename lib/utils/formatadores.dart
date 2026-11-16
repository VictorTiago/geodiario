import 'package:intl/intl.dart';

/// Funções auxiliares de formatação usadas nas telas.
class Formatadores {
  Formatadores._();

  static final _dataHora = DateFormat('dd/MM/yyyy HH:mm:ss');
  static final _dataCurta = DateFormat('dd/MM/yyyy HH:mm');

  static String dataHora(DateTime d) => _dataHora.format(d);
  static String dataCurta(DateTime d) => _dataCurta.format(d);

  /// Formata uma coordenada com 6 casas decimais (precisão de ~10 cm).
  static String coordenada(double valor) => valor.toStringAsFixed(6);

  static String latLong(double lat, double long) =>
      '${coordenada(lat)}, ${coordenada(long)}';
}
