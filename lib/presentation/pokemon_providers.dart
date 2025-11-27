import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/pokemon_entity.dart';
import '../domain/entities/pokemon_detail_entity.dart';
import '../domain/repositories/pokemon_repository.dart';
import '../domain/usecases/get_pokemon_list.dart';
import '../domain/usecases/get_pokemon_detail.dart';
import '../data/repositories/pokemon_repository_impl.dart';
import '../data/datasources/pokemon_remote_datasource.dart';
import '../data/datasources/pokemon_local_datasource.dart';
import '../data/datasources/pokemon_api_impl.dart';
import '../data/datasources/pokemon_database_impl.dart';

// ==================== Clean Architecture 依赖注入配置 ====================
//
// Riverpod Provider 作为依赖注入容器 (类似 Android Hilt/Koin)
// 从底层到顶层配置所有依赖:
// Data Sources → Repository → Use Cases → UI State
//
// 核心概念对比:
// - Provider ≈ Hilt 的 @Module + @Provides
// - StateNotifier ≈ ViewModel
// - ref.watch() ≈ Hilt 的 @Inject 依赖注入

// ==================== Data Layer Providers ====================

/// 远程数据源 Provider (API 网络请求)
///
/// 提供全局唯一的 Remote DataSource 实例
/// 类似 Hilt 中的:
/// @Singleton
/// @Provides
/// fun provideRemoteDataSource(): PokemonRemoteDataSource
final remoteDataSourceProvider = Provider<PokemonRemoteDataSource>((ref) {
  return PokemonRemoteDataSourceImpl();
});

/// 本地数据源 Provider (SQLite 数据库)
///
/// 提供全局唯一的 Local DataSource 实例
/// 类似 Hilt 中的:
/// @Singleton
/// @Provides
/// fun provideLocalDataSource(): PokemonLocalDataSource
final localDataSourceProvider = Provider<PokemonLocalDataSource>((ref) {
  return PokemonLocalDataSourceImpl();
});

// ==================== Repository Layer Provider ====================

/// Repository Provider（依赖注入 Data Sources）
///
/// 通过 ref.read() 注入远程和本地数据源
/// 类似 Hilt 中的:
/// @Singleton
/// @Provides
/// fun provideRepository(
///   remoteDataSource: PokemonRemoteDataSource,
///   localDataSource: PokemonLocalDataSource
/// ): PokemonRepository
final pokemonRepositoryProvider = Provider<PokemonRepository>((ref) {
  return PokemonRepositoryImpl(
    remoteDataSource: ref.read(remoteDataSourceProvider),
    localDataSource: ref.read(localDataSourceProvider),
  );
});

// ==================== Domain Layer - Use Cases Providers ====================

/// 获取 Pokemon 列表的 Use Case Provider
///
/// 注入 Repository 依赖
/// 类似 Hilt 中的:
/// @Provides
/// fun provideGetPokemonListUseCase(
///   repository: PokemonRepository
/// ): GetPokemonList
final getPokemonListUseCaseProvider = Provider<GetPokemonList>((ref) {
  return GetPokemonList(ref.read(pokemonRepositoryProvider));
});

/// 获取 Pokemon 详情的 Use Case Provider
///
/// 注入 Repository 依赖
/// 类似 Hilt 中的:
/// @Provides
/// fun provideGetPokemonDetailUseCase(
///   repository: PokemonRepository
/// ): GetPokemonDetail
final getPokemonDetailUseCaseProvider = Provider<GetPokemonDetail>((ref) {
  return GetPokemonDetail(ref.read(pokemonRepositoryProvider));
});

// ==================== Presentation Layer - UI State Management ====================

/// Pokemon 列表的 UI 状态
///
/// 使用 Domain Entity 而不是 Data Model
/// 类似 Android ViewModel 中的 UiState data class
///
/// 对应 Compose 中常见的模式:
/// data class PokemonListUiState(
///   val pokemonList: List<PokemonEntity> = emptyList(),
///   val isLoading: Boolean = false,
///   ...
/// )
class PokemonListState {
  final List<PokemonEntity> pokemonList;  // Pokemon 列表数据 (Domain Entity)
  final bool isLoading;                    // 首次加载状态
  final bool isLoadingMore;                // 加载更多状态（底部加载）
  final String? error;                     // 错误信息
  final int currentPage;                   // 当前页码
  final bool hasMore;                      // 是否还有更多数据

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
    List<PokemonEntity>? pokemonList,
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

/// Pokemon 列表的状态管理器 (使用 Use Case)
///
/// Clean Architecture 要求:
/// - ViewModel/Notifier 不直接依赖 Repository
/// - 而是依赖 Use Case（业务用例）
///
/// 类似 Android ViewModel:
/// class PokemonListViewModel @Inject constructor(
///   private val getPokemonListUseCase: GetPokemonList
/// ) : ViewModel() {
///   private val _uiState = MutableStateFlow(PokemonListUiState())
///   val uiState: StateFlow<PokemonListUiState> = _uiState
/// }
class PokemonListNotifier extends StateNotifier<PokemonListState> {
  final GetPokemonList _getPokemonListUseCase;

  /// 构造函数，注入 Use Case（不是 Repository）
  ///
  /// 这是 Clean Architecture 的关键:
  /// Presentation 层 → Use Case → Repository
  PokemonListNotifier(this._getPokemonListUseCase)
      : super(const PokemonListState()) {
    loadInitial();
  }

  /// 加载初始数据（第一页）
  ///
  /// 调用 Use Case 而不是直接调用 Repository
  /// 类似 ViewModel 中的:
  /// fun loadInitial() {
  ///   viewModelScope.launch {
  ///     val params = GetPokemonList.Params(page = 0)
  ///     val result = getPokemonListUseCase(params)
  ///     ...
  ///   }
  /// }
  Future<void> loadInitial() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      // 通过 Use Case 获取数据
      final pokemonList = await _getPokemonListUseCase(
        GetPokemonListParams(page: 0),
      );

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
    if (state.isLoadingMore || !state.hasMore) return; // 防止重复加载

    state = state.copyWith(isLoadingMore: true);

    try {
      final nextPage = state.currentPage + 1;

      // 通过 Use Case 获取下一页数据
      final newPokemon = await _getPokemonListUseCase(
        GetPokemonListParams(page: nextPage),
      );

      // 追加新数据到已有列表
      state = state.copyWith(
        pokemonList: [...state.pokemonList, ...newPokemon],
        isLoadingMore: false,
        currentPage: nextPage,
        hasMore: newPokemon.length >= 20, // 如果返回数据少于20条，说明没有更多了
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
      // 通过 Use Case 强制刷新数据
      final pokemonList = await _getPokemonListUseCase(
        GetPokemonListParams(page: 0, forceRefresh: true),
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
/// 注入 Use Case 而不是 Repository
/// UI 通过 ref.watch(pokemonListProvider) 监听状态变化
///
/// 类似 Compose 中的:
/// val viewModel: PokemonListViewModel = hiltViewModel()
/// val uiState by viewModel.uiState.collectAsState()
final pokemonListProvider =
    StateNotifierProvider<PokemonListNotifier, PokemonListState>((ref) {
  final getPokemonListUseCase = ref.read(getPokemonListUseCaseProvider);
  return PokemonListNotifier(getPokemonListUseCase);
});

// ==================== Pokemon 详情状态管理 ====================

/// Pokemon 详情 Provider（Family Pattern）
///
/// 使用 Use Case 获取详情数据
/// FutureProvider.family 用于根据参数创建不同的 Provider
/// 每个不同的 name 会创建独立的 Provider 实例并缓存结果
///
/// 类似 Android 中:
/// @Composable
/// fun PokemonDetailScreen(name: String) {
///   val viewModel: PokemonDetailViewModel = hiltViewModel()
///   val pokemonDetail by viewModel.getPokemonDetail(name).collectAsState()
/// }
///
/// [name] Pokemon 名称作为参数
final pokemonInfoProvider =
    FutureProvider.family<PokemonDetailEntity, String>((ref, name) async {
  // 通过 Use Case 获取详情数据
  final getPokemonDetailUseCase = ref.read(getPokemonDetailUseCaseProvider);
  return getPokemonDetailUseCase(GetPokemonDetailParams(name: name));
});

/// Pokemon 卡片颜色缓存 Provider
///
/// 用于缓存从图片提取的主色调，避免重复计算
/// StateProvider.family 为每个 pokemonId 创建独立的状态
///
/// 类似 Compose 中的:
/// val colors = remember(pokemonId) { mutableStateOf<Color?>(null) }
final pokemonColorProvider =
    StateProvider.family<Color?, int>((ref, pokemonId) => null);