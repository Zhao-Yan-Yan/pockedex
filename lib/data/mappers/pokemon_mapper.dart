import '../../domain/entities/pokemon_entity.dart';
import '../../domain/entities/pokemon_detail_entity.dart';
import '../models/pokemon.dart';
import '../models/pokemon_info.dart';

/// Data Model 到 Domain Entity 的映射器
///
/// Clean Architecture 要求 Data 层和 Domain 层的数据模型分离
/// - Data Model (Pokemon): 包含序列化逻辑,依赖具体框架
/// - Domain Entity (PokemonEntity): 纯业务对象,无框架依赖
///
/// Mapper 负责两者之间的转换
///
/// 类似 Android 中的 Mapper:
/// fun Pokemon.toEntity(): PokemonEntity
/// fun PokemonEntity.toModel(): Pokemon
extension PokemonMapper on Pokemon {
  /// 将 Data Model 转换为 Domain Entity
  PokemonEntity toEntity() {
    return PokemonEntity(
      id: id,
      name: name,
      imageUrl: imageUrl,
    );
  }
}

extension PokemonInfoMapper on PokemonInfo {
  /// 将详情 Model 转换为详情 Entity
  PokemonDetailEntity toEntity() {
    return PokemonDetailEntity(
      id: id,
      name: name,
      imageUrl: imageUrl,
      height: height,
      weight: weight,
      baseExperience: baseExperience,
      types: types.map((t) => t.toEntity()).toList(),
      stats: stats.map((s) => s.toEntity()).toList(),
    );
  }
}

extension PokemonTypeMapper on PokemonType {
  PokemonTypeEntity toEntity() {
    return PokemonTypeEntity(name: name);
  }
}

extension PokemonStatMapper on PokemonStat {
  PokemonStatEntity toEntity() {
    return PokemonStatEntity(
      name: name,
      baseStat: baseStat,
    );
  }
}