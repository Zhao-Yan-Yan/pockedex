import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/pokemon.dart';
import '../../providers/pokemon_providers.dart';
import '../widgets/pokemon_card.dart';
import '../widgets/theme_selector.dart';
import 'detail_page.dart';

/// 首页：Pokemon 列表页
///
/// 功能:
/// 1. 网格展示 Pokemon 列表
/// 2. 滚动到底部自动加载更多（分页）
/// 3. 下拉刷新
/// 4. 点击卡片跳转详情页
/// 5. 错误处理和重试
///
/// ConsumerStatefulWidget 结合了 Riverpod 状态监听和 StatefulWidget 的生命周期
///
/// 类似 Compose 中的:
/// @Composable
/// fun HomePage(viewModel: PokemonViewModel = viewModel()) {
///   val state by viewModel.uiState.collectAsState()
///   val scrollState = rememberLazyGridState()
///   LazyVerticalGrid(...) { ... }
/// }
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  // ScrollController 用于监听滚动事件
  // 类似 Android RecyclerView.addOnScrollListener()
  // 或 Compose 的 LazyListState
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // 添加滚动监听器（用于实现分页加载）
    // 类似 RecyclerView 的 addOnScrollListener
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    // 释放资源（必须！）
    // 类似 Android View 的 onDetachedFromWindow
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// 滚动监听：实现无限滚动分页
  ///
  /// 当距离底部还有 400 像素时，触发加载更多
  /// 类似 Android Paging 库的自动加载或 Compose Paging
  void _onScroll() {
    // 预加载阈值：距离底部 400px 时开始加载
    // 类似 RecyclerView.addOnScrollListener 判断是否到底部
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 400) {
      // 触发 ViewModel 的 loadMore 方法
      // ref.read() 用于一次性读取和调用方法（不监听）
      ref.read(pokemonListProvider.notifier).loadMore();
    }
  }

  /// 导航到详情页
  ///
  /// 使用 PageRouteBuilder 自定义页面转场动画
  /// 类似 Android 的 ActivityOptionsCompat 或 Compose Navigation
  void _navigateToDetail(Pokemon pokemon) {
    Navigator.of(context).push(
      PageRouteBuilder(
        // 转场动画时长
        transitionDuration: const Duration(milliseconds: 550),
        reverseTransitionDuration: const Duration(milliseconds: 550),
        // 构建目标页面
        pageBuilder: (context, animation, secondaryAnimation) {
          return DetailPage(pokemon: pokemon);
        },
        // 自定义转场动画（淡入淡出）
        // 类似 Android 的 Fade Transition
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ref.watch() 监听 Provider 的状态变化
    // 当状态改变时，UI 会自动重建
    // 类似 Compose 的 collectAsState()
    final state = ref.watch(pokemonListProvider);

    // 获取主题主色调,用于背景渐变
    final primaryColor = Theme.of(context).colorScheme.primary;
    final backgroundColor = Theme.of(context).colorScheme.surface;

    // Scaffold 是 Material Design 的页面骨架
    // 提供 AppBar、Body、FloatingActionButton 等标准布局
    // 类似 Android 的 CoordinatorLayout + AppBarLayout
    return Scaffold(
      // AppBar 顶部标题栏
      // 类似 Android Toolbar 或 Compose TopAppBar
      appBar: AppBar(
        title: const Text(
          'Pokedex',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,  // 标题左对齐
        backgroundColor: Colors.transparent,  // 透明背景,让渐变效果穿透
        elevation: 0,  // 无阴影
        // 右上角主题切换按钮
        // 类似 Android 的 Menu 或 Compose TopAppBar actions
        actions: [
          IconButton(
            icon: const Icon(Icons.palette_outlined),
            tooltip: '主题设置',
            onPressed: () {
              // 显示主题选择器弹窗
              showThemeSelector(context);
            },
          ),
        ],
      ),
      // extendBodyBehindAppBar: 让 body 延伸到 AppBar 后面
      // 使背景渐变效果能覆盖整个屏幕
      extendBodyBehindAppBar: true,
      // 使用 Container 包裹 body,添加渐变背景
      // 类似 Android 的 GradientDrawable 或 Compose Brush.verticalGradient
      body: Container(
        // 线性渐变背景
        // 从顶部主题色淡化到底部背景色
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              // 顶部:主题色的淡化版本
              primaryColor.withValues(alpha: 0.08),
              // 中部:更淡的过渡
              primaryColor.withValues(alpha: 0.03),
              // 底部:纯背景色
              backgroundColor,
            ],
            stops: const [0.0, 0.3, 1.0],  // 渐变停止点
          ),
        ),
        // SafeArea 确保内容不被系统 UI(如状态栏)遮挡
        // 类似 Android 的 WindowInsets
        // bottom: false 让内容延伸到底部导航栏后面,实现沉浸式效果
        child: SafeArea(
          bottom: false,  // 底部不留安全区域,实现沉浸式
          child: _buildBody(state),
        ),
      ),
    );
  }

  /// 构建页面主体内容
  ///
  /// 根据状态展示不同的 UI:
  /// - 首次加载：显示 Loading
  /// - 加载失败：显示错误提示
  /// - 加载成功：显示网格列表
  Widget _buildBody(PokemonListState state) {
    // 首次加载中
    if (state.isLoading && state.pokemonList.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),  // 类似 Android ProgressBar
      );
    }

    // 加载失败（且没有缓存数据）
    if (state.error != null && state.pokemonList.isEmpty) {
      return _buildErrorView(state.error!);
    }

    // 正常显示列表
    // RefreshIndicator: 下拉刷新组件
    // 类似 Android SwipeRefreshLayout
    return RefreshIndicator(
      onRefresh: () => ref.read(pokemonListProvider.notifier).refresh(),
      // CustomScrollView: 支持 Sliver 的高级滚动视图
      // Sliver 是 Flutter 中可滚动 Widget 的底层构建块
      // 类似 Android RecyclerView 的灵活性
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),  // 即使内容不足也允许滚动（支持下拉刷新）
        slivers: [
          // SliverPadding: 带内边距的 Sliver
          SliverPadding(
            padding: const EdgeInsets.all(16),
            // SliverGrid: 网格布局
            // 类似 Android StaggeredGridLayoutManager
            // 或 Compose 的 LazyVerticalGrid
            sliver: SliverGrid(
              // 网格配置：2列
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,        // 2列
                mainAxisSpacing: 8,       // 垂直间距
                crossAxisSpacing: 8,      // 水平间距
                childAspectRatio: 0.85,   // 宽高比
              ),
              // 子项构建器（懒加载）
              // 类似 RecyclerView.Adapter 的 onCreateViewHolder + onBindViewHolder
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final pokemon = state.pokemonList[index];
                  return PokemonCard(
                    pokemon: pokemon,
                    onTap: () => _navigateToDetail(pokemon),
                  );
                },
                childCount: state.pokemonList.length,
              ),
            ),
          ),
          // 底部加载更多指示器
          // if 条件渲染，类似 Compose 的 if (condition) { ... }
          if (state.isLoadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          // 底部安全区域占位
          // 确保最后一行内容不被底部导航栏遮挡
          // 类似 Android 的 bottomNavigationBarHeight padding
          SliverPadding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 16,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建错误提示视图
  ///
  /// 显示错误图标、错误信息和重试按钮
  /// 类似 Android 的 Error State View 或 Compose 的 ErrorScreen
  Widget _buildErrorView(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        // Column 垂直布局，类似 Compose Column
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 错误图标
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),  // 间距
            // 错误信息
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            // 重试按钮
            // ElevatedButton: Material Design 的凸起按钮
            // 类似 Android Button 或 Compose Button
            ElevatedButton.icon(
              onPressed: () {
                // 调用 ViewModel 的重新加载方法
                ref.read(pokemonListProvider.notifier).loadInitial();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }
}