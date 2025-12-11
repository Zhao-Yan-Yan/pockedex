import 'dart:convert';

import 'package:flutter/material.dart';

import 'pokemon_move.dart';

/// Pokemon type with color mapping
class PokemonType {
  final int slot;
  final String name;

  PokemonType({
    required this.slot,
    required this.name,
  });

  /// Get display name with first letter capitalized
  String get displayName {
    if (name.isEmpty) return name;
    return name[0].toUpperCase() + name.substring(1);
  }

  /// Get color for this type
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

  factory PokemonType.fromJson(Map<String, dynamic> json) {
    return PokemonType(
      slot: json['slot'] as int,
      name: (json['type'] as Map<String, dynamic>)['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'slot': slot,
      'name': name,
    };
  }
}

/// Pokemon stat
class PokemonStat {
  final String name;
  final int baseStat;

  PokemonStat({
    required this.name,
    required this.baseStat,
  });

  /// Get abbreviated display name
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

  /// Get max value for this stat
  int get maxValue {
    return 300;
  }

  factory PokemonStat.fromJson(Map<String, dynamic> json) {
    return PokemonStat(
      name: (json['stat'] as Map<String, dynamic>)['name'] as String,
      baseStat: json['base_stat'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'baseStat': baseStat,
    };
  }
}

/// Detailed Pokemon information
class PokemonInfo {
  final int id;
  final String name;
  final int height;
  final int weight;
  final int baseExperience;
  final List<PokemonType> types;
  final List<PokemonStat> stats;
  final List<PokemonMove> moves;
  final String? evolutionChainUrl;  // 进化链 URL（需要从 species API 获取）

  PokemonInfo({
    required this.id,
    required this.name,
    required this.height,
    required this.weight,
    required this.baseExperience,
    required this.types,
    required this.stats,
    this.moves = const [],
    this.evolutionChainUrl,
  });

  /// Get formatted ID string (e.g., #001)
  String get idString {
    return '#${id.toString().padLeft(3, '0')}';
  }

  /// Get display name with first letter capitalized
  String get displayName {
    if (name.isEmpty) return name;
    return name[0].toUpperCase() + name.substring(1);
  }

  /// Get formatted height string (in meters)
  String get heightString {
    return '${(height / 10).toStringAsFixed(1)} M';
  }

  /// Get formatted weight string (in kilograms)
  String get weightString {
    return '${(weight / 10).toStringAsFixed(1)} KG';
  }

  /// Get official artwork image URL
  String get imageUrl {
    return 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';
  }

  /// Get HP stat
  int get hp => _getStatValue('hp');

  /// Get Attack stat
  int get attack => _getStatValue('attack');

  /// Get Defense stat
  int get defense => _getStatValue('defense');

  /// Get Speed stat
  int get speed => _getStatValue('speed');

  int _getStatValue(String statName) {
    final stat = stats.firstWhere(
      (s) => s.name == statName,
      orElse: () => PokemonStat(name: statName, baseStat: 0),
    );
    return stat.baseStat;
  }

  /// Get primary type color
  Color get primaryColor {
    if (types.isEmpty) return Colors.grey;
    return types.first.color;
  }

  /// 获取按等级排序的技能列表（只显示通过升级学会的）
  List<PokemonMove> get levelUpMoves {
    return moves
        .where((move) => move.learnLevel != null)
        .toList()
      ..sort((a, b) => a.learnLevel!.compareTo(b.learnLevel!));
  }

  /// 获取进化链 ID
  int? get evolutionChainId {
    if (evolutionChainUrl == null) return null;
    final uri = Uri.parse(evolutionChainUrl!);
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    return int.tryParse(segments.last);
  }

  factory PokemonInfo.fromJson(Map<String, dynamic> json) {
    return PokemonInfo(
      id: json['id'] as int,
      name: json['name'] as String,
      height: json['height'] as int,
      weight: json['weight'] as int,
      baseExperience: json['base_experience'] as int? ?? 0,
      types: (json['types'] as List)
          .map((e) => PokemonType.fromJson(e as Map<String, dynamic>))
          .toList(),
      stats: (json['stats'] as List)
          .map((e) => PokemonStat.fromJson(e as Map<String, dynamic>))
          .toList(),
      moves: json['moves'] != null
          ? (json['moves'] as List)
              .map((e) => PokemonMove.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
      evolutionChainUrl: json['evolution_chain_url'] as String?,
    );
  }

  Map<String, dynamic> toDbJson() {
    return {
      'id': id,
      'name': name,
      'height': height,
      'weight': weight,
      'base_experience': baseExperience,
      'types': jsonEncode(types.map((e) => e.toJson()).toList()),
      'stats': jsonEncode(stats.map((e) => e.toJson()).toList()),
      'moves': jsonEncode(moves.map((e) => e.toJson()).toList()),
      'evolution_chain_url': evolutionChainUrl,
    };
  }

  factory PokemonInfo.fromDb(Map<String, dynamic> map) {
    final typesJson = jsonDecode(map['types'] as String) as List;
    final statsJson = jsonDecode(map['stats'] as String) as List;
    final movesJson = map['moves'] != null
        ? jsonDecode(map['moves'] as String) as List
        : <dynamic>[];

    return PokemonInfo(
      id: map['id'] as int,
      name: map['name'] as String,
      height: map['height'] as int,
      weight: map['weight'] as int,
      baseExperience: map['base_experience'] as int,
      types: typesJson
          .map((e) => PokemonType(
                slot: e['slot'] as int,
                name: e['name'] as String,
              ))
          .toList(),
      stats: statsJson
          .map((e) => PokemonStat(
                name: e['name'] as String,
                baseStat: e['baseStat'] as int,
              ))
          .toList(),
      moves: movesJson
          .map((e) => PokemonMove(
                name: e['name'] as String,
                learnMethods: (e['learnMethods'] as List)
                    .map((m) => MoveLearnMethod(
                          name: m['name'] as String,
                          level: m['level'] as int,
                        ))
                    .toList(),
              ))
          .toList(),
      evolutionChainUrl: map['evolution_chain_url'] as String?,
    );
  }
}