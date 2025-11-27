import '../entities/pokemon_entity.dart';
import '../repositories/pokemon_repository.dart';

/// 获取 Pokemon 列表用例 (Use Case)
///
/// Clean Architecture 的核心：业务逻辑封装在用例中
/// - 每个用例代表一个具体的业务操作
/// - 用例协调 Repository 和 Entity
/// - UI 层通过用例访问业务逻辑，而不是直接访问 Repository
///
/// 单一职责原则：一个用例只做一件事
///
/// 类似 Android Clean Architecture 中的:
/// class GetPokemonListUseCase(private val repository: PokemonRepository) {
///   suspend operator fun invoke(params: Params): List<PokemonEntity>
/// }
class GetPokemonList {
  final PokemonRepository repository;

  /// 构造函数注入 Repository
  ///
  /// 依赖倒置：依赖抽象接口，不依赖具体实现
  GetPokemonList(this.repository);

  /// 执行用例
  ///
  /// [params] 用例参数
  /// 返回 Pokemon 实体列表
  ///
  /// Dart 不支持 operator fun invoke，所以使用 call 方法
  /// 使用方式: final result = await getPokemonList(params)
  Future<List<PokemonEntity>> call(GetPokemonListParams params) async {
    return await repository.getPokemonList(
      page: params.page,
      forceRefresh: params.forceRefresh,
    );
  }
}

/// 用例参数
///
/// 封装用例所需的所有参数
/// 类似 Kotlin 的 data class Params
class GetPokemonListParams {
  final int page;
  final bool forceRefresh;

  const GetPokemonListParams({
    required this.page,
    this.forceRefresh = false,
  });
}