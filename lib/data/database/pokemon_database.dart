import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/pokemon.dart';
import '../models/pokemon_info.dart';

/// SQLite 数据库管理类
///
/// 对应 Android 中的 RoomDatabase
/// 使用 sqflite (Flutter 版的 SQLite) 实现本地数据持久化
///
/// 功能:
/// - 缓存 Pokemon 列表数据
/// - 缓存 Pokemon 详情数据
/// - 支持离线访问
class PokemonDatabase {
  static const String _dbName = 'pokemon.db';           // 数据库文件名
  static const int _dbVersion = 4;                      // 数据库版本（用于迁移）

  static const String _tablePokemon = 'pokemon';        // 列表数据表名
  static const String _tablePokemonInfo = 'pokemon_info'; // 详情数据表名
  static const String _tableFavorites = 'favorites';    // 收藏数据表名

  Database? _database;  // 数据库实例（懒加载）

  /// 获取数据库实例（单例模式）
  ///
  /// 类似 Room.databaseBuilder().build()
  /// 首次调用时初始化数据库，后续直接返回已有实例
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// 初始化数据库
  ///
  /// 获取数据库路径并创建数据库文件
  /// Android 上路径类似: /data/data/com.example.app/databases/pokemon.db
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,  // 首次创建时的回调
      onUpgrade: _onUpgrade, // 数据库升级时的回调
    );
  }

  /// 数据库创建时的回调（只会执行一次）
  ///
  /// 类似 Room 中的 @Database(entities = [...])
  /// 创建表结构和索引
  Future<void> _onCreate(Database db, int version) async {
    // 创建 Pokemon 列表表
    await db.execute('''
      CREATE TABLE $_tablePokemon (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        page INTEGER NOT NULL,
        name TEXT NOT NULL,
        url TEXT NOT NULL,
        UNIQUE(name)
      )
    ''');

    // 创建 Pokemon 详情表
    await db.execute('''
      CREATE TABLE $_tablePokemonInfo (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL UNIQUE,
        height INTEGER NOT NULL,
        weight INTEGER NOT NULL,
        base_experience INTEGER NOT NULL,
        types TEXT NOT NULL,       -- JSON 字符串存储复杂对象
        stats TEXT NOT NULL,       -- JSON 字符串存储复杂对象
        moves TEXT,                -- JSON 字符串存储技能列表
        evolution_chain_url TEXT   -- 进化链 URL
      )
    ''');

    // 创建收藏表
    await db.execute('''
      CREATE TABLE $_tableFavorites (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL UNIQUE,
        added_time INTEGER NOT NULL  -- 添加到收藏夹的时间戳（毫秒）
      )
    ''');

    // 创建索引以提升查询性能
    // 类似 Room 中的 @Index(value = ["page"])
    await db.execute(
        'CREATE INDEX idx_pokemon_page ON $_tablePokemon (page)');
    await db.execute(
        'CREATE INDEX idx_pokemon_info_name ON $_tablePokemonInfo (name)');
    await db.execute(
        'CREATE INDEX idx_favorites_name ON $_tableFavorites (name)');
  }

  /// 数据库升级回调
  ///
  /// 处理数据库版本升级时的表结构变更
  /// 类似 Room 的 Migration
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // 从版本1升级到版本2：添加收藏表
      await db.execute('''
        CREATE TABLE $_tableFavorites (
          id INTEGER PRIMARY KEY,
          name TEXT NOT NULL UNIQUE,
          added_time INTEGER NOT NULL
        )
      ''');
      await db.execute(
          'CREATE INDEX idx_favorites_name ON $_tableFavorites (name)');
    }

    if (oldVersion < 3) {
      // 从版本2升级到版本3：添加技能和进化链字段
      await db.execute(
          'ALTER TABLE $_tablePokemonInfo ADD COLUMN moves TEXT');
      await db.execute(
          'ALTER TABLE $_tablePokemonInfo ADD COLUMN evolution_chain_url TEXT');

      // 清除旧的详情数据，强制重新获取包含技能的完整数据
      await db.delete(_tablePokemonInfo);
    }

    if (oldVersion < 4) {
      // 从版本3升级到版本4：清除所有可能包含空技能数据的缓存
      // 修复之前版本中 moves 字段为 NULL 的问题
      await db.delete(_tablePokemonInfo);
    }
  }

  // ==================== Pokemon 列表操作 ====================
  // 类似 Room 中的 @Dao interface

  /// 根据页码获取 Pokemon 列表
  ///
  /// 类似 Room 的 @Query("SELECT * FROM pokemon WHERE page = :page")
  Future<List<Pokemon>> getPokemonListByPage(int page) async {
    final db = await database;
    final results = await db.query(
      _tablePokemon,
      where: 'page = ?',
      whereArgs: [page],
    );
    return results.map((e) => Pokemon.fromDb(e)).toList();
  }

  /// 批量插入 Pokemon 列表
  ///
  /// 使用 batch 操作提升性能（类似 Room 的 @Insert）
  /// ConflictAlgorithm.replace: 冲突时替换旧数据
  Future<void> insertPokemonList(List<Pokemon> pokemonList) async {
    final db = await database;
    final batch = db.batch();  // 批量操作，减少 IO 次数
    for (final pokemon in pokemonList) {
      batch.insert(
        _tablePokemon,
        pokemon.toDb(),
        conflictAlgorithm: ConflictAlgorithm.replace,  // 类似 @Insert(onConflict = REPLACE)
      );
    }
    await batch.commit(noResult: true);  // 提交事务
  }

  // ==================== Pokemon 详情操作 ====================

  /// 根据名称获取 Pokemon 详情
  ///
  /// 类似 Room 的 @Query("SELECT * FROM pokemon_info WHERE name = :name")
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

  /// 插入 Pokemon 详情
  ///
  /// 类似 Room 的 @Insert(onConflict = REPLACE)
  Future<void> insertPokemonInfo(PokemonInfo info) async {
    final db = await database;
    await db.insert(
      _tablePokemonInfo,
      info.toDbJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ==================== 收藏操作 ====================

  /// 添加到收藏
  ///
  /// [pokemonId] Pokemon ID
  /// [pokemonName] Pokemon 名称
  /// 类似 Room 的 @Insert(onConflict = REPLACE)
  Future<void> addToFavorites(int pokemonId, String pokemonName) async {
    final db = await database;
    await db.insert(
      _tableFavorites,
      {
        'id': pokemonId,
        'name': pokemonName,
        'added_time': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 从收藏中移除
  ///
  /// [pokemonId] Pokemon ID
  /// 类似 Room 的 @Delete
  Future<void> removeFromFavorites(int pokemonId) async {
    final db = await database;
    await db.delete(
      _tableFavorites,
      where: 'id = ?',
      whereArgs: [pokemonId],
    );
  }

  /// 检查是否已收藏
  ///
  /// [pokemonId] Pokemon ID
  /// 返回 true 表示已收藏，false 表示未收藏
  Future<bool> isFavorite(int pokemonId) async {
    final db = await database;
    final results = await db.query(
      _tableFavorites,
      where: 'id = ?',
      whereArgs: [pokemonId],
    );
    return results.isNotEmpty;
  }

  /// 获取所有收藏的 Pokemon ID 列表
  ///
  /// 按添加时间倒序排列（最新添加的在前面）
  /// 类似 Room 的 @Query("SELECT id FROM favorites ORDER BY added_time DESC")
  Future<List<int>> getFavoritePokemonIds() async {
    final db = await database;
    final results = await db.query(
      _tableFavorites,
      columns: ['id'],
      orderBy: 'added_time DESC',
    );
    return results.map((e) => e['id'] as int).toList();
  }

  /// 获取所有收藏的 Pokemon（带完整信息）
  ///
  /// 通过 JOIN 查询获取收藏的 Pokemon 列表信息
  /// 按添加时间倒序排列
  Future<List<Pokemon>> getFavoritePokemonList() async {
    final db = await database;
    final results = await db.rawQuery('''
      SELECT p.* FROM $_tablePokemon p
      INNER JOIN $_tableFavorites f ON p.name = f.name
      ORDER BY f.added_time DESC
    ''');
    return results.map((e) => Pokemon.fromDb(e)).toList();
  }

  /// 关闭数据库连接
  ///
  /// 释放资源（一般在应用退出时调用）
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}