import '../entities/pokemon_entity.dart';
import '../entities/pokemon_detail_entity.dart';

/// Pokemon Repository 抽象接口 (Domain 层)
///
/// Clean Architecture 的核心原则：依赖倒置
/// - Domain 层定义接口（抽象）
/// - Data 层实现接口（具体）
/// - 高层模块不依赖低层模块，都依赖抽象
///
/// 类似 Android Clean Architecture 中的:
/// interface PokemonRepository {
///   suspend fun getPokemonList(page: Int): List<PokemonEntity>
///   suspend fun getPokemonDetail(name: String): PokemonDetailEntity
/// }
abstract class PokemonRepository {
  /// 获取 Pokemon 列表
  ///
  /// [page] 页码，从 0 开始
  /// [forceRefresh] 是否强制刷新（绕过缓存）
  ///
  /// 返回 Pokemon 实体列表
  /// 类似 Kotlin: suspend fun getPokemonList(page: Int, forceRefresh: Boolean): List<PokemonEntity>
  Future<List<PokemonEntity>> getPokemonList({
    required int page,
    bool forceRefresh = false,
  });

  /// 获取 Pokemon 详情
  ///
  /// [name] Pokemon 名称
  /// [forceRefresh] 是否强制刷新
  ///
  /// 返回 Pokemon 详情实体
  /// 类似 Kotlin: suspend fun getPokemonDetail(name: String, forceRefresh: Boolean): PokemonDetailEntity
  Future<PokemonDetailEntity> getPokemonDetail({
    required String name,
    bool forceRefresh = false,
  });
}