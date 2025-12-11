/// Pokemon 技能数据模型
///
/// 对应 PokeAPI 的 move 数据结构

/// 技能学习方式
class MoveLearnMethod {
  final String name;
  final int level;

  MoveLearnMethod({
    required this.name,
    required this.level,
  });

  /// 获取学习方式的显示名称
  String get displayName {
    switch (name) {
      case 'level-up':
        return 'Level $level';
      case 'machine':
        return 'TM/HM';
      case 'egg':
        return 'Egg Move';
      case 'tutor':
        return 'Tutor';
      default:
        return name;
    }
  }

  factory MoveLearnMethod.fromJson(Map<String, dynamic> json) {
    return MoveLearnMethod(
      name: (json['move_learn_method'] as Map<String, dynamic>)['name'] as String,
      level: json['level_learned_at'] as int? ?? 0,
    );
  }
}

/// Pokemon 技能
class PokemonMove {
  final String name;
  final List<MoveLearnMethod> learnMethods;

  PokemonMove({
    required this.name,
    required this.learnMethods,
  });

  /// 获取显示名称（格式化技能名）
  String get displayName {
    // 将 "thunder-punch" 转换为 "Thunder Punch"
    return name.split('-').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  /// 获取主要学习方式（优先显示升级学会的等级）
  String get primaryLearnMethod {
    // 优先显示 level-up 方式
    final levelUp = learnMethods.firstWhere(
      (method) => method.name == 'level-up',
      orElse: () => learnMethods.first,
    );
    return levelUp.displayName;
  }

  /// 获取学会的等级（如果通过升级学会）
  int? get learnLevel {
    final levelUp = learnMethods.where((method) => method.name == 'level-up');
    if (levelUp.isEmpty) return null;
    return levelUp.first.level;
  }

  factory PokemonMove.fromJson(Map<String, dynamic> json) {
    return PokemonMove(
      name: (json['move'] as Map<String, dynamic>)['name'] as String,
      learnMethods: (json['version_group_details'] as List)
          .map((e) => MoveLearnMethod.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'learnMethods': learnMethods.map((e) => {
        'name': e.name,
        'level': e.level,
      }).toList(),
    };
  }
}