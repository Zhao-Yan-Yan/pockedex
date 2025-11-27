import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/pokemon.dart';
import '../models/pokemon_info.dart';
import 'pokemon_local_datasource.dart';

/// Pokemon 本地数据源实现 (使用 SQLite)
///
/// 实现 PokemonLocalDataSource 接口
/// 负责本地数据库操作的具体实现
///
/// 类似 Android Room DAO 的实现
class PokemonLocalDataSourceImpl implements PokemonLocalDataSource {
  static const String _dbName = 'pokemon.db';
  static const int _dbVersion = 1;
  static const String _tablePokemon = 'pokemon';
  static const String _tablePokemonInfo = 'pokemon_info';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tablePokemon (
        page INTEGER NOT NULL,
        name TEXT NOT NULL,
        url TEXT NOT NULL,
        PRIMARY KEY (name)
      )
    ''');

    await db.execute('''
      CREATE TABLE $_tablePokemonInfo (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL UNIQUE,
        height INTEGER NOT NULL,
        weight INTEGER NOT NULL,
        base_experience INTEGER NOT NULL,
        types TEXT NOT NULL,
        stats TEXT NOT NULL
      )
    ''');

    await db.execute(
        'CREATE INDEX idx_pokemon_page ON $_tablePokemon (page)');
    await db.execute(
        'CREATE INDEX idx_pokemon_info_name ON $_tablePokemonInfo (name)');
  }

  @override
  Future<List<Pokemon>> getPokemonListByPage(int page) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tablePokemon,
      where: 'page = ?',
      whereArgs: [page],
    );
    return List.generate(maps.length, (i) => Pokemon.fromDb(maps[i]));
  }

  @override
  Future<void> cachePokemonList(List<Pokemon> pokemonList) async {
    final db = await database;
    final batch = db.batch();
    for (final pokemon in pokemonList) {
      batch.insert(
        _tablePokemon,
        pokemon.toDb(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<PokemonInfo?> getPokemonDetail(String name) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tablePokemonInfo,
      where: 'name = ?',
      whereArgs: [name],
    );

    if (maps.isEmpty) return null;
    return PokemonInfo.fromDb(maps.first);
  }

  @override
  Future<void> cachePokemonDetail(PokemonInfo info) async {
    final db = await database;
    await db.insert(
      _tablePokemonInfo,
      info.toDbJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}