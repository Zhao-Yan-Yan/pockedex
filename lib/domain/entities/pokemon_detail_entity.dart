import 'package:flutter/material.dart';

/// Pokemon 详情业务实体
///
/// 包含 Pokemon 的完整信息
/// 纯业务对象，不包含任何框架依赖
class PokemonDetailEntity {
  final int id;
  final String name;
  final String imageUrl;
  final int height;      // 分米为单位
  final int weight;      // 百克为单位
  final int baseExperience;
  final List<PokemonTypeEntity> types;
  final List<PokemonStatEntity> stats;

  const PokemonDetailEntity({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.height,
    required this.weight,
    required this.baseExperience,
    required this.types,
    required this.stats,
  });

  /// 显示名称（首字母大写）
  String get displayName {
    if (name.isEmpty) return name;
    return name[0].toUpperCase() + name.substring(1);
  }

  /// ID 显示格式 (#001)
  String get idString {
    return '#${id.toString().padLeft(3, '0')}';
  }

  /// 身高显示格式 (m)
  String get heightString {
    return '${(height / 10).toStringAsFixed(1)} m';
  }

  /// 体重显示格式 (kg)
  String get weightString {
    return '${(weight / 10).toStringAsFixed(1)} kg';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PokemonDetailEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Pokemon 类型实体
class PokemonTypeEntity {
  final String name;

  const PokemonTypeEntity({required this.name});

  /// 显示名称（首字母大写）
  String get displayName {
    if (name.isEmpty) return name;
    return name[0].toUpperCase() + name.substring(1);
  }

  /// 类型对应的颜色
  ///
  /// 从 Data 层移到 Domain 层
  /// 虽然颜色是 UI 相关，但类型颜色是业务规则的一部分
  Color get color {
    return _typeColors[name] ?? Colors.grey;
  }

  static const Map<String, Color> _typeColors = {
    'fighting': Color(0xFFC22E28),
    'flying': Color(0xFFA98FF3),
    'poison': Color(0xFFA33EA1),
    'ground': Color(0xFFE2BF65),
    'rock': Color(0xFFB6A136),
    'bug': Color(0xFFA6B91A),
    'ghost': Color(0xFF735797),
    'steel': Color(0xFFB7B7CE),
    'fire': Color(0xFFEE8130),
    'water': Color(0xFF6390F0),
    'grass': Color(0xFF7AC74C),
    'electric': Color(0xFFF7D02C),
    'psychic': Color(0xFFF95587),
    'ice': Color(0xFF96D9D6),
    'dragon': Color(0xFF6F35FC),
    'dark': Color(0xFF705746),
    'fairy': Color(0xFFD685AD),
    'normal': Color(0xFFA8A77A),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PokemonTypeEntity &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;
}

/// Pokemon 能力值实体
class PokemonStatEntity {
  final String name;
  final int baseStat;

  const PokemonStatEntity({
    required this.name,
    required this.baseStat,
  });

  /// 显示名称（缩写）
  String get displayName {
    switch (name) {
      case 'hp':
        return 'HP';
      case 'attack':
        return 'ATK';
      case 'defense':
        return 'DEF';
      case 'special-attack':
        return 'SATK';
      case 'special-defense':
        return 'SDEF';
      case 'speed':
        return 'SPD';
      default:
        return name.toUpperCase();
    }
  }

  /// 最大值（用于进度条）
  int get maxValue => 255;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PokemonStatEntity &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;
}