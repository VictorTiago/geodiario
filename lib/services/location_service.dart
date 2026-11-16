import 'dart:async';

import 'package:geolocator/geolocator.dart';

/// Erro de localização com uma mensagem amigável para exibir ao usuário.
class LocalizacaoException implements Exception {
  final String mensagem;

  /// Indica que a permissão foi negada permanentemente e o usuário
  /// precisa liberá-la nas configurações do aparelho.
  final bool abrirConfiguracoes;

  const LocalizacaoException(this.mensagem, {this.abrirConfiguracoes = false});

  @override
  String toString() => mensagem;
}

/// Serviço de acesso ao GPS (baseado no material "GPS no FlutLab").
class LocationService {
  /// Verifica serviço e permissões e retorna a posição atual do dispositivo.
  /// Lança [LocalizacaoException] quando não for possível obter a posição.
  Future<Position> obterPosicaoAtual() async {
    // 1. Verifica se o serviço de localização do aparelho está ativo.
    final servicoAtivo = await Geolocator.isLocationServiceEnabled();
    if (!servicoAtivo) {
      throw const LocalizacaoException(
        'O GPS/serviço de localização está desativado no dispositivo.',
      );
    }

    // 2. Verifica (e, se necessário, solicita) a permissão do aplicativo.
    var permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
      if (permissao == LocationPermission.denied) {
        throw const LocalizacaoException(
          'Permissão de localização negada pelo usuário.',
        );
      }
    }

    // 3. Permissão negada permanentemente: só pode ser liberada nas configurações.
    if (permissao == LocationPermission.deniedForever) {
      throw const LocalizacaoException(
        'A permissão de localização foi negada permanentemente. '
        'Ative-a nas configurações do aplicativo.',
        abrirConfiguracoes: true,
      );
    }

    // 4. Captura a posição atual com alta precisão.
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
    } on TimeoutException {
      // Se o GPS demorar demais, usa a última posição conhecida (se houver).
      final ultima = await Geolocator.getLastKnownPosition();
      if (ultima != null) return ultima;
      throw const LocalizacaoException(
        'Não foi possível obter a localização a tempo. Tente novamente.',
      );
    }
  }

  /// Abre a tela de configurações do aplicativo no sistema operacional.
  Future<void> abrirConfiguracoesDoApp() => Geolocator.openAppSettings();
}
