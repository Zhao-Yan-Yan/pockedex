import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/pokemon.dart';
import '../data/models/pokemon_info.dart';
import '../data/repository/pokemon_repository.dart';

// ==================== Riverpod 状态管理 ====================
//
// Riverpod 是 Flutter 推荐的状态管理库（Provider 的升级版）
// 对应 Android 中的 ViewModel + LiveData/StateFlow
//
// 核心概念对比:
// - Provider ≈ Hilt/Dagger 依赖注入
// - StateNotifier ≈ ViewModel
// - State ≈ UiState data class
// - ref.watch() ≈ collectAsState() (Compose中)

/// Repository Provider（单例）
///
/// 提供全局唯一的 Repository 实例
/// 类似 Hilt 中的 @Singleton + @Provides
final pokemonRepositoryProvider = Provider<PokemonRepository>((ref) {
  return PokemonRepository();
});

// ==================== Pokemon 列表状态管理 ====================

/// Pokemon 列表的 UI 状态
///
/// 类似 Android ViewModel 中的 UiState data class
/// 包含列表数据、加载状态、错误信息等
///
/// 对应 Compose 中常见的模式:
/// data class PokemonListUiState(
///   val pokemonList: List<Pokemon> = emptyList(),
///   val isLoading: Boolean = false,
///   ...
/// )
class PokemonListState {
  final List<Pokemon> pokemonList;  // Pokemon 列表数据
  final bool isLoading;             // 首次加载状态
  final bool isLoadingMore;         // 加载更多状态（底部加载）
  final String? error;              // 错误信息
  final int currentPage;            // 当前页码
  final bool hasMore;               // 是否还有更多数据

  const PokemonListState({
    this.pokemonList = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.currentPage = 0,
    this.hasMore = true,
  });

  /// 创建新状态（不可变数据）
  ///
  /// Dart 中的 immutable 数据模式
  /// 类似 Kotlin 的 data class.copy() 方法
  PokemonListState copyWith({
    List<Pokemon>? pokemonList,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? currentPage,
    bool? hasMore,
  }) {
    return PokemonListState(
      pokemonList: pokemonList ?? this.pokemonList,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

/// Pokemon 列表的状态管理器
///
/// 类似 Android ViewModel，负责:
/// 1. 管理 UI 状态
/// 2. 处理业务逻辑（调用 Repository）
/// 3. 更新状态并通知 UI 刷新
///
/// StateNotifier<State> ≈ ViewModel with StateFlow<UiState>
class PokemonListNotifier extends StateNotifier<PokemonListState> {
  final PokemonRepository _repository;

  /// 构造函数，初始化时自动加载第一页数据
  ///
  /// 类似 ViewModel 的 init {} 块
  PokemonListNotifier(this._repository) : super(const PokemonListState()) {
    loadInitial();
  }

  /// 加载初始数据（第一页）
  ///
  /// 类似 ViewModel 中的:
  /// fun loadInitial() {
  ///   viewModelScope.launch {
  ///     _uiState.value = _uiState.value.copy(isLoading = true)
  ///     ...
  ///   }
  /// }
  Future<void> loadInitial() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final pokemonList = await _repository.fetchPokemonList(page: 0);
      state = state.copyWith(
        pokemonList: pokemonList,
        isLoading: false,
        currentPage: 0,
        hasMore: pokemonList.length >= 20,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 加载更多数据（分页）
  ///
  /// 当用户滚动到列表底部时调用
  /// 类似 Android Paging 库的自动加载
  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;  // 防止重复加载

    state = state.copyWith(isLoadingMore: true);

    try {
      final nextPage = state.currentPage + 1;
      final newPokemon = await _repository.fetchPokemonList(page: nextPage);

      // 追加新数据到已有列表
      state = state.copyWith(
        pokemonList: [...state.pokemonList, ...newPokemon],
        isLoadingMore: false,
        currentPage: nextPage,
        hasMore: newPokemon.length >= 20,  // 如果返回数据少于20条，说明没有更多了
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  /// 下拉刷新
  ///
  /// 清空现有数据，重新加载第一页（强制刷新）
  /// 类似 SwipeRefreshLayout 的刷新逻辑
  Future<void> refresh() async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      pokemonList: [],
      currentPage: 0,
      hasMore: true,
    );

    try {
      final pokemonList = await _repository.fetchPokemonList(
        page: 0,
        forceRefresh: true,
      );
      state = state.copyWith(
        pokemonList: pokemonList,
        isLoading: false,
        hasMore: pokemonList.length >= 20,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

/// Pokemon 列表 Provider（全局状态）
///
/// UI 通过 ref.watch(pokemonListProvider) 监听状态变化
/// 类似 Compose 中的:
/// val uiState by viewModel.uiState.collectAsState()
///
/// StateNotifierProvider ≈ viewModel() in Compose
final pokemonListProvider =
    StateNotifierProvider<PokemonListNotifier, PokemonListState>((ref) {
  final repository = ref.watch(pokemonRepositoryProvider);  // 依赖注入
  return PokemonListNotifier(repository);
});

// ==================== Pokemon 详情状态管理 ====================

/// Pokemon 详情的 UI 状态（未使用，仅作示例）
///
/// 本项目使用 FutureProvider 替代了 StateNotifier
class PokemonInfoState {
  final PokemonInfo? info;
  final bool isLoading;
  final String? error;

  const PokemonInfoState({
    this.info,
    this.isLoading = false,
    this.error,
  });

  PokemonInfoState copyWith({
    PokemonInfo? info,
    bool? isLoading,
    String? error,
  }) {
    return PokemonInfoState(
      info: info ?? this.info,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Pokemon 详情 Provider（Family Pattern）
///
/// FutureProvider.family 用于根据参数创建不同的 Provider
/// 每个不同的 name 会创建独立的 Provider 实例并缓存结果
///
/// 类似 Android 中:
/// val pokemonInfo = remember(name) {
///   viewModel.getPokemonInfo(name)
/// }.collectAsState()
///
/// [name] Pokemon 名称作为参数
final pokemonInfoProvider = FutureProvider.family<PokemonInfo, String>(
  (ref, name) async {
    final repository = ref.watch(pokemonRepositoryProvider);
    return repository.fetchPokemonInfo(name: name);
  },
);

/// Pokemon 卡片颜色缓存 Provider
///
/// 用于缓存从图片提取的主色调，避免重复计算
/// StateProvider.family 为每个 pokemonId 创建独立的状态
///
/// 类似 Compose 中的:
/// val colors = remember(pokemonId) { mutableStateOf<Color?>(null) }
final pokemonColorProvider =
    StateProvider.family<Color?, int>((ref, pokemonId) => null);

// ==================== 收藏功能状态管理 ====================

/// 收藏功能的 UI 状态
///
/// 类似 Android ViewModel 中的 UiState data class
class FavoriteState {
  final Set<int> favoriteIds;   // 收藏的 Pokemon ID 集合（用于快速查找）
  final List<Pokemon> favorites; // 收藏的 Pokemon 列表（用于显示）
  final bool isLoading;          // 加载状态
  final String? error;           // 错误信息

  const FavoriteState({
    this.favoriteIds = const {},
    this.favorites = const [],
    this.isLoading = false,
    this.error,
  });

  /// 创建新状态（不可变数据）
  FavoriteState copyWith({
    Set<int>? favoriteIds,
    List<Pokemon>? favorites,
    bool? isLoading,
    String? error,
  }) {
    return FavoriteState(
      favoriteIds: favoriteIds ?? this.favoriteIds,
      favorites: favorites ?? this.favorites,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// 收藏功能的状态管理器
///
/// 类似 Android ViewModel，负责:
/// 1. 管理收藏状态
/// 2. 处理添加/移除收藏的业务逻辑
/// 3. 更新状态并通知 UI 刷新
class FavoriteNotifier extends StateNotifier<FavoriteState> {
  final PokemonRepository _repository;

  /// 构造函数，初始化时自动加载收藏列表
  FavoriteNotifier(this._repository) : super(const FavoriteState()) {
    loadFavorites();
  }

  /// 加载收藏列表
  ///
  /// 从数据库获取所有收藏的 Pokemon
  Future<void> loadFavorites() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final favoriteIds = await _repository.getFavoritePokemonIds();
      final favorites = await _repository.getFavoritePokemonList();

      state = state.copyWith(
        favoriteIds: favoriteIds.toSet(),
        favorites: favorites,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 切换收藏状态
  ///
  /// 如果已收藏则移除，未收藏则添加
  /// [pokemonId] Pokemon ID
  /// [pokemonName] Pokemon 名称
  Future<void> toggleFavorite(int pokemonId, String pokemonName) async {
    try {
      await _repository.toggleFavorite(pokemonId, pokemonName);

      // 更新本地状态
      final newFavoriteIds = Set<int>.from(state.favoriteIds);
      if (newFavoriteIds.contains(pokemonId)) {
        newFavoriteIds.remove(pokemonId);
      } else {
        newFavoriteIds.add(pokemonId);
      }

      state = state.copyWith(favoriteIds: newFavoriteIds);

      // 重新加载收藏列表以获取完整信息
      await loadFavorites();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// 检查是否已收藏
  ///
  /// [pokemonId] Pokemon ID
  bool isFavorite(int pokemonId) {
    return state.favoriteIds.contains(pokemonId);
  }
}

/// 收藏功能 Provider（全局状态）
///
/// UI 通过 ref.watch(favoriteProvider) 监听状态变化
/// 类似 Compose 中的:
/// val favoriteState by viewModel.favoriteState.collectAsState()
final favoriteProvider =
    StateNotifierProvider<FavoriteNotifier, FavoriteState>((ref) {
  final repository = ref.watch(pokemonRepositoryProvider);
  return FavoriteNotifier(repository);
});