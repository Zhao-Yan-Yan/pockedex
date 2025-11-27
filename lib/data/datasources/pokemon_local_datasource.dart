import '../models/pokemon.dart';
import '../models/pokemon_info.dart';

/// Pokemon 本地数据源抽象接口
///
/// 定义本地缓存的操作接口
/// Repository 通过此接口访问本地数据，不关心具体实现(SQLite/Hive/SharedPreferences)
abstract class PokemonLocalDataSource {
  /// 从本地获取 Pokemon 列表
  Future<List<Pokemon>> getPokemonListByPage(int page);

  /// 缓存 Pokemon 列表
  Future<void> cachePokemonList(List<Pokemon> pokemonList);

  /// 从本地获取 Pokemon 详情
  Future<PokemonInfo?> getPokemonDetail(String name);

  /// 缓存 Pokemon 详情
  Future<void> cachePokemonDetail(PokemonInfo info);
}