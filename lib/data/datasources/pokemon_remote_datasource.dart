import '../models/pokemon.dart';
import '../models/pokemon_info.dart';

/// Pokemon 远程数据源抽象接口
///
/// Clean Architecture 数据层的抽象
/// - Repository 依赖此接口，不依赖具体实现
/// - 便于测试时 Mock
/// - 便于切换不同的网络实现
///
/// 类似 Android 的:
/// interface PokemonRemoteDataSource {
///   suspend fun fetchPokemonList(page: Int): PokemonListResponse
/// }
abstract class PokemonRemoteDataSource {
  /// 从网络获取 Pokemon 列表
  Future<PokemonListResponse> fetchPokemonList(int page);

  /// 从网络获取 Pokemon 详情
  Future<PokemonInfo> fetchPokemonDetail(String name);
}