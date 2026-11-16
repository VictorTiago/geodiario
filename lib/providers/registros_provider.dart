import 'package:flutter/foundation.dart';

import '../database/database_helper.dart';
import '../models/registro.dart';
import '../services/camera_service.dart';

/// Gerencia o estado da lista de registros (padrão Provider + ChangeNotifier).
///
/// Faz a ponte entre as telas e a camada de dados: toda alteração é gravada
/// no SQLite e, em seguida, os widgets interessados são notificados.
class RegistrosProvider with ChangeNotifier {
  RegistrosProvider({DatabaseHelper? db, CameraService? cameraService})
      : _db = db ?? DatabaseHelper.instance,
        _cameraService = cameraService ?? CameraService();

  final DatabaseHelper _db;
  final CameraService _cameraService;

  final List<Registro> _itens = [];
  bool _carregando = false;

  /// Cópia da lista para evitar modificações externas.
  List<Registro> get todos => List.unmodifiable(_itens);
  int get quantidade => _itens.length;
  bool get carregando => _carregando;

  /// READ – carrega todos os registros do banco.
  Future<void> carregar() async {
    _carregando = true;
    notifyListeners();
    try {
      final registros = await _db.listarTodos();
      _itens
        ..clear()
        ..addAll(registros);
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  /// CREATE – grava um novo registro e o insere no topo da lista.
  Future<void> adicionar(Registro registro) async {
    final id = await _db.inserir(registro);
    _itens.insert(0, registro.copyWith(id: id));
    notifyListeners();
  }

  /// DELETE – remove o registro do banco e o arquivo de imagem correspondente.
  Future<void> excluir(Registro registro) async {
    if (registro.id == null) return;
    await _db.excluir(registro.id!);
    await _cameraService.excluirFoto(registro.caminhoFoto);
    _itens.removeWhere((r) => r.id == registro.id);
    notifyListeners();
  }
}
