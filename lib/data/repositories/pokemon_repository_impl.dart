import '../../domain/entities/pokemon_entity.dart';
import '../../domain/entities/pokemon_detail_entity.dart';
import '../../domain/repositories/pokemon_repository.dart';
import '../datasources/pokemon_local_datasource.dart';
import '../datasources/pokemon_remote_datasource.dart';
import '../mappers/pokemon_mapper.dart';

/// Pokemon Repository 实现类 (Data 层)
///
/// 实现 Domain 层定义的 PokemonRepository 接口
/// 协调远程数据源和本地数据源，实现缓存优先策略
///
/// 依赖倒置原则的体现:
/// - 依赖 RemoteDataSource 和 LocalDataSource 的抽象接口
/// - 不依赖具体实现(API/Database)
///
/// 类似 Android Clean Architecture 中的 RepositoryImpl
class PokemonRepositoryImpl implements PokemonRepository {
  final PokemonRemoteDataSource remoteDataSource;
  final PokemonLocalDataSource localDataSource;

  /// 构造函数注入数据源
  ///
  /// 依赖抽象，不依赖具体实现
  PokemonRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<PokemonEntity>> getPokemonList({
    required int page,
    bool forceRefresh = false,
  }) async {
    // 缓存优先策略
    if (!forceRefresh) {
      final cachedData = await localDataSource.getPokemonListByPage(page);
      if (cachedData.isNotEmpty) {
        // 使用 Mapper 将 Model 转换为 Entity
        return cachedData.map((model) => model.toEntity()).toList();
      }
    }

    // 从远程获取
    final response = await remoteDataSource.fetchPokemonList(page);

    // 缓存到本地
    await localDataSource.cachePokemonList(response.results);

    // 转换为 Entity 返回
    return response.results.map((model) => model.toEntity()).toList();
  }

  @override
  Future<PokemonDetailEntity> getPokemonDetail({
    required String name,
    bool forceRefresh = false,
  }) async {
    // 缓存优先
    if (!forceRefresh) {
      final cachedData = await localDataSource.getPokemonDetail(name);
      if (cachedData != null) {
        return cachedData.toEntity();
      }
    }

    // 从远程获取
    final data = await remoteDataSource.fetchPokemonDetail(name);

    // 缓存到本地
    await localDataSource.cachePokemonDetail(data);

    // 转换为 Entity 返回
    return data.toEntity();
  }
}