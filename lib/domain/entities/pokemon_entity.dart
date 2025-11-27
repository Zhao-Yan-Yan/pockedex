/// Pokemon 业务实体 (Domain Entity)
///
/// Clean Architecture 核心层的实体
/// - 不依赖任何外部框架
/// - 包含核心业务逻辑和规则
/// - 类似 Android Clean Architecture 中的 Entity
///
/// 对比:
/// - Entity ≈ 纯业务对象，不包含序列化逻辑
/// - Model (Data层) ≈ DTO，包含 JSON 序列化
class PokemonEntity {
  final int id;
  final String name;
  final String imageUrl;

  const PokemonEntity({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  /// 获取显示名称（首字母大写）
  ///
  /// 业务规则：名称必须首字母大写显示
  String get displayName {
    if (name.isEmpty) return name;
    return name[0].toUpperCase() + name.substring(1);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PokemonEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}