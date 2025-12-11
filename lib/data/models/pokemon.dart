/// Pokemon 列表项数据模型
///
/// 对应 Android 中的 data class，用于列表展示
/// 类似 Jetpack Compose 中的数据类，但 Dart 需要手动实现构造函数
class Pokemon {
  final int page;       // 所属页码，用于分页加载
  final String name;    // 宝可梦名称（小写）
  final String url;     // API 详情接口地址
  final bool isFavorite; // 是否已收藏

  Pokemon({
    required this.page,
    required this.name,
    required this.url,
    this.isFavorite = false, // 默认未收藏
  });

  /// 从 URL 中解析出宝可梦 ID
  /// 例如: https://pokeapi.co/api/v2/pokemon/25/ -> 25
  /// 类似 Kotlin 的计算属性 val id: Int get() = ...
  int get id {
    final uri = Uri.parse(url);
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    return int.parse(segments.last);
  }

  /// 获取首字母大写的显示名称
  /// 例如: "pikachu" -> "Pikachu"
  String get displayName {
    if (name.isEmpty) return name;
    return name[0].toUpperCase() + name.substring(1);
  }

  /// 获取官方高清图片 URL
  /// 使用 GitHub 上的 PokeAPI 图片资源
  String get imageUrl {
    return 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';
  }

  /// 从 API JSON 响应创建对象
  /// Dart 使用 factory 构造函数实现类似 Gson/Moshi 的反序列化
  /// 对应 Android 中的 @Serializable 或 @JsonClass
  factory Pokemon.fromJson(Map<String, dynamic> json, int page, {bool isFavorite = false}) {
    return Pokemon(
      page: page,
      name: json['name'] as String,
      url: json['url'] as String,
      isFavorite: isFavorite,
    );
  }

  /// 转换为 JSON (用于缓存或调试)
  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'name': name,
      'url': url,
    };
  }

  /// 从数据库 Map 创建对象
  /// SQLite 返回的是 Map<String, dynamic>
  factory Pokemon.fromDb(Map<String, dynamic> map, {bool isFavorite = false}) {
    return Pokemon(
      page: map['page'] as int,
      name: map['name'] as String,
      url: map['url'] as String,
      isFavorite: isFavorite,
    );
  }

  /// 复制对象并更新收藏状态
  /// 类似 Kotlin data class 的 copy 方法
  Pokemon copyWith({bool? isFavorite}) {
    return Pokemon(
      page: page,
      name: name,
      url: url,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  /// 转换为数据库 Map（用于存储）
  Map<String, dynamic> toDb() {
    return {
      'page': page,
      'name': name,
      'url': url,
    };
  }
}

/// Pokemon 列表 API 响应模型
///
/// 对应 PokeAPI 的分页响应结构
/// 类似 Android Paging 库中的 PagingData
class PokemonListResponse {
  final int count;              // 总数量
  final String? next;           // 下一页 URL (可能为 null)
  final String? previous;       // 上一页 URL (可能为 null)
  final List<Pokemon> results;  // 当前页数据列表

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