/// Pokemon 遇敌地点数据模型
///
/// 对应 PokeAPI 的 location area encounters 数据结构

/// 遇敌详情
class EncounterDetail {
  final int chance;             // 遇敌概率（0-100）
  final int minLevel;           // 最低等级
  final int maxLevel;           // 最高等级
  final String method;          // 遇敌方式（walk, surf, fish等）

  EncounterDetail({
    required this.chance,
    required this.minLevel,
    required this.maxLevel,
    required this.method,
  });

  /// 获取等级范围显示
  String get levelRange {
    if (minLevel == maxLevel) {
      return 'Lv.$minLevel';
    }
    return 'Lv.$minLevel-$maxLevel';
  }

  /// 获取遇敌方式显示名称
  String get methodDisplay {
    return method.split('-').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  factory EncounterDetail.fromJson(Map<String, dynamic> json) {
    return EncounterDetail(
      chance: json['chance'] as int,
      minLevel: json['min_level'] as int,
      maxLevel: json['max_level'] as int,
      method: (json['method'] as Map<String, dynamic>)['name'] as String,
    );
  }
}

/// 版本遇敌信息
class VersionEncounter {
  final String version;
  final List<EncounterDetail> details;

  VersionEncounter({
    required this.version,
    required this.details,
  });

  /// 获取最高遇敌概率
  int get maxChance {
    if (details.isEmpty) return 0;
    return details.map((d) => d.chance).reduce((a, b) => a > b ? a : b);
  }

  /// 获取等级范围
  String get levelRange {
    if (details.isEmpty) return '';
    final minLevel = details.map((d) => d.minLevel).reduce((a, b) => a < b ? a : b);
    final maxLevel = details.map((d) => d.maxLevel).reduce((a, b) => a > b ? a : b);
    if (minLevel == maxLevel) {
      return 'Lv.$minLevel';
    }
    return 'Lv.$minLevel-$maxLevel';
  }

  factory VersionEncounter.fromJson(Map<String, dynamic> json) {
    return VersionEncounter(
      version: (json['version'] as Map<String, dynamic>)['name'] as String,
      details: (json['encounter_details'] as List)
          .map((e) => EncounterDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// 地点遇敌信息
class LocationEncounter {
  final String locationName;
  final List<VersionEncounter> versionDetails;

  LocationEncounter({
    required this.locationName,
    required this.versionDetails,
  });

  /// 获取地点显示名称
  String get displayName {
    return locationName.split('-').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  /// 获取最新版本的遇敌信息（简化展示）
  VersionEncounter? get latestVersion {
    if (versionDetails.isEmpty) return null;
    return versionDetails.last;
  }

  factory LocationEncounter.fromJson(Map<String, dynamic> json) {
    return LocationEncounter(
      locationName: (json['location_area'] as Map<String, dynamic>)['name'] as String,
      versionDetails: (json['version_details'] as List)
          .map((e) => VersionEncounter.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}