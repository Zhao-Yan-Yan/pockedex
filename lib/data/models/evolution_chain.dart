/// Pokemon 进化链数据模型
///
/// 对应 PokeAPI 的 evolution-chain 数据结构

/// 进化详情（进化条件）
class EvolutionDetail {
  final String? trigger;        // 进化触发方式（level-up, use-item, trade等）
  final int? minLevel;          // 最低等级要求
  final String? item;           // 需要的道具
  final String? heldItem;       // 需要携带的道具
  final String? timeOfDay;      // 时间要求（day/night）
  final String? location;       // 地点要求
  final int? minHappiness;      // 最低好感度

  EvolutionDetail({
    this.trigger,
    this.minLevel,
    this.item,
    this.heldItem,
    this.timeOfDay,
    this.location,
    this.minHappiness,
  });

  /// 获取进化条件的简短描述
  String get description {
    final List<String> conditions = [];

    if (minLevel != null && minLevel! > 0) {
      conditions.add('Lv.$minLevel');
    }

    if (item != null) {
      conditions.add(_formatName(item!));
    }

    if (heldItem != null) {
      conditions.add('Hold ${_formatName(heldItem!)}');
    }

    if (timeOfDay != null && timeOfDay!.isNotEmpty) {
      conditions.add(_formatName(timeOfDay!));
    }

    if (location != null) {
      conditions.add(_formatName(location!));
    }

    if (minHappiness != null && minHappiness! > 0) {
      conditions.add('Happiness $minHappiness');
    }

    if (conditions.isEmpty) {
      return trigger != null ? _formatName(trigger!) : 'Unknown';
    }

    return conditions.join(', ');
  }

  String _formatName(String name) {
    return name.split('-').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  factory EvolutionDetail.fromJson(Map<String, dynamic> json) {
    return EvolutionDetail(
      trigger: json['trigger'] != null
          ? (json['trigger'] as Map<String, dynamic>)['name'] as String?
          : null,
      minLevel: json['min_level'] as int?,
      item: json['item'] != null
          ? (json['item'] as Map<String, dynamic>)['name'] as String?
          : null,
      heldItem: json['held_item'] != null
          ? (json['held_item'] as Map<String, dynamic>)['name'] as String?
          : null,
      timeOfDay: json['time_of_day'] as String?,
      location: json['location'] != null
          ? (json['location'] as Map<String, dynamic>)['name'] as String?
          : null,
      minHappiness: json['min_happiness'] as int?,
    );
  }
}

/// 进化链中的一个物种
class ChainLink {
  final String speciesName;     // 物种名称
  final int speciesId;          // 物种 ID
  final bool isBaby;            // 是否是幼年形态
  final List<EvolutionDetail> evolutionDetails;  // 进化条件列表
  final List<ChainLink> evolvesTo;  // 可进化到的形态列表

  ChainLink({
    required this.speciesName,
    required this.speciesId,
    this.isBaby = false,
    this.evolutionDetails = const [],
    this.evolvesTo = const [],
  });

  /// 获取显示名称
  String get displayName {
    if (speciesName.isEmpty) return speciesName;
    return speciesName[0].toUpperCase() + speciesName.substring(1);
  }

  /// 获取图片 URL
  String get imageUrl {
    return 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$speciesId.png';
  }

  /// 从 species URL 中提取 ID
  static int _extractIdFromUrl(String url) {
    final uri = Uri.parse(url);
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    return int.parse(segments.last);
  }

  factory ChainLink.fromJson(Map<String, dynamic> json) {
    final species = json['species'] as Map<String, dynamic>;
    final speciesUrl = species['url'] as String;

    return ChainLink(
      speciesName: species['name'] as String,
      speciesId: _extractIdFromUrl(speciesUrl),
      isBaby: json['is_baby'] as bool? ?? false,
      evolutionDetails: json['evolution_details'] != null
          ? (json['evolution_details'] as List)
              .map((e) => EvolutionDetail.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
      evolvesTo: json['evolves_to'] != null
          ? (json['evolves_to'] as List)
              .map((e) => ChainLink.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
    );
  }
}

/// 完整的进化链
class EvolutionChain {
  final int id;
  final ChainLink chain;

  EvolutionChain({
    required this.id,
    required this.chain,
  });

  /// 获取扁平化的进化链列表（用于简单展示）
  List<ChainLink> get flatChain {
    final List<ChainLink> result = [];
    _flattenChain(chain, result);
    return result;
  }

  void _flattenChain(ChainLink link, List<ChainLink> result) {
    result.add(link);
    for (final evolution in link.evolvesTo) {
      _flattenChain(evolution, result);
    }
  }

  factory EvolutionChain.fromJson(Map<String, dynamic> json) {
    return EvolutionChain(
      id: json['id'] as int,
      chain: ChainLink.fromJson(json['chain'] as Map<String, dynamic>),
    );
  }
}