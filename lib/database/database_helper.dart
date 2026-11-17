import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/registro.dart';

/// Responsável por toda a comunicação com o banco SQLite (sqflite).
///
/// Implementado como Singleton para que exista uma única conexão aberta
/// com o banco durante a execução do aplicativo.
class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static const _nomeBanco = 'geodiario.db';
  static const _versaoBanco = 1;
  static const tabela = 'registros';

  Database? _db;

  /// Retorna a conexão com o banco, abrindo-a na primeira chamada.
  Future<Database> get database async {
    _db ??= await _abrirBanco();
    return _db!;
  }

  Future<Database> _abrirBanco() async {
    final pastaBancos = await getDatabasesPath();
    final caminho = join(pastaBancos, _nomeBanco);

    return openDatabase(
      caminho,
      version: _versaoBanco,
      // Executado apenas uma vez, quando o banco é criado.
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tabela (
            id            INTEGER PRIMARY KEY AUTOINCREMENT,
            titulo        TEXT    NOT NULL,
            descricao     TEXT,
            caminho_foto  TEXT    NOT NULL,
            data_hora     TEXT    NOT NULL,
            latitude      REAL    NOT NULL,
            longitude     REAL    NOT NULL
          )
        ''');
      },
    );
  }

  /// CREATE: insere um registro e retorna o id gerado.
  Future<int> inserir(Registro registro) async {
    final db = await database;
    return db.insert(tabela, registro.toMap());
  }

  /// READ: retorna todos os registros, do mais recente para o mais antigo.
  Future<List<Registro>> listarTodos() async {
    final db = await database;
    final linhas = await db.query(tabela, orderBy: 'data_hora DESC');
    return linhas.map(Registro.fromMap).toList();
  }

  /// READ: busca um registro pelo id.
  Future<Registro?> buscarPorId(int id) async {
    final db = await database;
    final linhas = await db.query(
      tabela,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return linhas.isEmpty ? null : Registro.fromMap(linhas.first);
  }

  /// DELETE: remove um registro pelo id e retorna a quantidade removida.
  Future<int> excluir(int id) async {
    final db = await database;
    return db.delete(tabela, where: 'id = ?', whereArgs: [id]);
  }
}
