import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/pokemon.dart';
import '../models/pokemon_info.dart';

class PokemonDatabase {
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
    // Create pokemon table for list
    await db.execute('''
      CREATE TABLE $_tablePokemon (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        page INTEGER NOT NULL,
        name TEXT NOT NULL,
        url TEXT NOT NULL,
        UNIQUE(name)
      )
    ''');

    // Create pokemon_info table for details
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

    // Create indexes
    await db.execute(
        'CREATE INDEX idx_pokemon_page ON $_tablePokemon (page)');
    await db.execute(
        'CREATE INDEX idx_pokemon_info_name ON $_tablePokemonInfo (name)');
  }

  // Pokemon list operations
  Future<List<Pokemon>> getPokemonListByPage(int page) async {
    final db = await database;
    final results = await db.query(
      _tablePokemon,
      where: 'page = ?',
      whereArgs: [page],
    );
    return results.map((e) => Pokemon.fromDb(e)).toList();
  }

  Future<void> insertPokemonList(List<Pokemon> pokemonList) async {
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

  // Pokemon info operations
  Future<PokemonInfo?> getPokemonInfo(String name) async {
    final db = await database;
    final results = await db.query(
      _tablePokemonInfo,
      where: 'name = ?',
      whereArgs: [name],
    );
    if (results.isEmpty) return null;
    return PokemonInfo.fromDb(results.first);
  }

  Future<void> insertPokemonInfo(PokemonInfo info) async {
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