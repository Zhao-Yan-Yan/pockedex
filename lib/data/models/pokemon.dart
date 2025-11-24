/// Pokemon model for list display
class Pokemon {
  final int page;
  final String name;
  final String url;

  Pokemon({
    required this.page,
    required this.name,
    required this.url,
  });

  /// Get Pokemon ID from URL
  int get id {
    final uri = Uri.parse(url);
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    return int.parse(segments.last);
  }

  /// Get display name with first letter capitalized
  String get displayName {
    if (name.isEmpty) return name;
    return name[0].toUpperCase() + name.substring(1);
  }

  /// Get official artwork image URL
  String get imageUrl {
    return 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';
  }

  factory Pokemon.fromJson(Map<String, dynamic> json, int page) {
    return Pokemon(
      page: page,
      name: json['name'] as String,
      url: json['url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'name': name,
      'url': url,
    };
  }

  factory Pokemon.fromDb(Map<String, dynamic> map) {
    return Pokemon(
      page: map['page'] as int,
      name: map['name'] as String,
      url: map['url'] as String,
    );
  }

  Map<String, dynamic> toDb() {
    return {
      'page': page,
      'name': name,
      'url': url,
    };
  }
}

/// Response model for Pokemon list API
class PokemonListResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<Pokemon> results;

  PokemonListResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PokemonListResponse.fromJson(Map<String, dynamic> json, int page) {
    return PokemonListResponse(
      count: json['count'] as int,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: (json['results'] as List)
          .map((e) => Pokemon.fromJson(e as Map<String, dynamic>, page))
          .toList(),
    );
  }
}