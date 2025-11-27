import '../entities/pokemon_detail_entity.dart';
import '../repositories/pokemon_repository.dart';

/// 获取 Pokemon 详情用例
///
/// 封装获取单个 Pokemon 详细信息的业务逻辑
class GetPokemonDetail {
  final PokemonRepository repository;

  GetPokemonDetail(this.repository);

  /// 执行用例
  ///
  /// [params] 用例参数
  /// 返回 Pokemon 详情实体
  Future<PokemonDetailEntity> call(GetPokemonDetailParams params) async {
    return await repository.getPokemonDetail(
      name: params.name,
      forceRefresh: params.forceRefresh,
    );
  }
}

/// 用例参数
class GetPokemonDetailParams {
  final String name;
  final bool forceRefresh;

  const GetPokemonDetailParams({
    required this.name,
    this.forceRefresh = false,
  });
}