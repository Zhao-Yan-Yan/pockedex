import '../api/pokemon_api.dart';
import '../database/pokemon_database.dart';
import '../models/pokemon.dart';
import '../models/pokemon_info.dart';

/// Pokemon 数据仓库层
///
/// 对应 Android 架构中的 Repository 层
/// 负责协调 API（网络数据源）和 Database（本地数据源）
///
/// 实现缓存优先策略（Cache-First Strategy）:
/// 1. 先尝试从本地数据库获取数据
/// 2. 如果本地无数据或需要刷新，则从网络获取
/// 3. 网络数据获取后自动缓存到本地
///
/// 类似 Android Jetpack 的 Repository 模式
class PokemonRepository {
  final PokemonApi _api;            // 网络数据源
  final PokemonDatabase _database;  // 本地数据源

  /// 构造函数，支持依赖注入（便于测试）
  ///
  /// [api] 网络 API 实例
  /// [database] 数据库实例
  PokemonRepository({
    PokemonApi? api,
    PokemonDatabase? database,
  })  : _api = api ?? PokemonApi(),
        _database = database ?? PokemonDatabase();

  /// 获取 Pokemon 列表（带缓存策略）
  ///
  /// 执行流程:
  /// 1. 如果 forceRefresh=false，先查本地缓存
  /// 2. 缓存命中直接返回，缓存未命中则请求网络
  /// 3. 网络数据返回后自动存入本地缓存
  ///
  /// [page] 页码
  /// [forceRefresh] 是否强制刷新（下拉刷新时设为 true）
  ///
  /// 类似 Android Paging 库的 RemoteMediator
  Future<List<Pokemon>> fetchPokemonList({
    required int page,
    bool forceRefresh = false,
  }) async {
    // 第一步: 如果不是强制刷新，先尝试从缓存获取
    if (!forceRefresh) {
      final cached = await _database.getPokemonListByPage(page);
      if (cached.isNotEmpty) {
        return cached;  // 缓存命中，直接返回
      }
    }

    // 第二步: 从网络获取数据
    final response = await _api.fetchPokemonList(page: page);

    // 第三步: 将网络数据缓存到本地
    await _database.insertPokemonList(response.results);

    return response.results;
  }

  /// 获取 Pokemon 详情（带缓存策略）
  ///
  /// 执行流程同上
  ///
  /// [name] Pokemon 名称
  /// [forceRefresh] 是否强制刷新
  ///
  /// 类似 Room + Retrofit 的单一数据源模式（Single Source of Truth）
  Future<PokemonInfo> fetchPokemonInfo({
    required String name,
    bool forceRefresh = false,
  }) async {
    // 第一步: 如果不是强制刷新，先尝试从缓存获取
    if (!forceRefresh) {
      final cached = await _database.getPokemonInfo(name);
      if (cached != null) {
        return cached;  // 缓存命中，直接返回
      }
    }

    // 第二步: 从网络获取数据
    final info = await _api.fetchPokemonInfo(name);

    // 第三步: 将网络数据缓存到本地
    await _database.insertPokemonInfo(info);

    return info;
  }
}