import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/pokemon.dart';
import '../../data/models/pokemon_info.dart';
import '../../providers/pokemon_providers.dart';
import '../widgets/stat_bar.dart';
import '../widgets/moves_list.dart';

/// Pokemon 详情页
///
/// 功能:
/// 1. 展示 Pokemon 详细信息（图片、名称、ID、类型）
/// 2. 展示物理信息（身高、体重）
/// 3. 展示能力值（HP、攻击、防御等）带动画
/// 4. 可折叠 AppBar（SliverAppBar）
/// 5. Hero 动画支持（共享元素转场）
///
/// ConsumerWidget 是 Riverpod 的无状态组件
/// 类似 Compose 中监听 ViewModel 的 @Composable 函数
///
/// 对比:
/// - ConsumerWidget ≈ @Composable + collectAsState()
/// - 不需要管理内部状态，只监听外部 Provider
class DetailPage extends ConsumerWidget {
  final Pokemon pokemon;  // 从列表页传递的基础信息

  const DetailPage({
    super.key,
    required this.pokemon,
  });

  /// 构建 UI
  ///
  /// WidgetRef 用于访问 Riverpod Provider
  /// 类似 Compose 中函数参数直接访问 ViewModel
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 监听详情数据的异步加载状态
    // pokemonInfoProvider 是 FutureProvider
    // ref.watch() 会自动处理 loading/data/error 三种状态
    final pokemonInfoAsync = ref.watch(pokemonInfoProvider(pokemon.name));

    // 获取缓存的主色调（从列表页提取的颜色）
    final cachedColor = ref.watch(pokemonColorProvider(pokemon.id));
    final backgroundColor = cachedColor ?? Colors.grey.shade300;

    return Scaffold(
      // pokemonInfoAsync.when() 处理异步状态
      // 类似 Compose 中的 when (uiState) { ... }
      // 或 Android 的 sealed class + when 表达式
      body: pokemonInfoAsync.when(
        data: (info) => _buildContent(context, info, backgroundColor),      // 加载成功
        loading: () => _buildLoadingContent(context, backgroundColor),      // 加载中
        error: (error, stack) => _buildErrorContent(context, error.toString()), // 加载失败
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, PokemonInfo info, Color backgroundColor) {
    final lightColor = Color.lerp(backgroundColor, Colors.white, 0.3)!;

    return Container(
      // 设置背景色,避免圆角后露出黑色
      color: lightColor,
      child: CustomScrollView(
        slivers: [
          _buildAppBar(context, info, lightColor),
          SliverToBoxAdapter(
            child: _buildDetails(context, info, backgroundColor),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingContent(BuildContext context, Color backgroundColor) {
    final lightColor = Color.lerp(backgroundColor, Colors.white, 0.3)!;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 280,
          pinned: true,
          backgroundColor: lightColor,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              color: lightColor,
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Hero(
                      tag: 'pokemon-image-${pokemon.id}',
                      child: CachedNetworkImage(
                        imageUrl: pokemon.imageUrl,
                        width: 180,
                        height: 180,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SliverFillRemaining(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorContent(BuildContext context, String error) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pokemon.displayName),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(error),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(
      BuildContext context, PokemonInfo info, Color backgroundColor) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: backgroundColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        // 收藏按钮
        Consumer(
          builder: (context, ref, child) {
            final favoriteNotifier = ref.watch(favoriteProvider.notifier);
            final isFavorite = ref.watch(favoriteProvider
                .select((state) => state.favoriteIds.contains(pokemon.id)));

            return IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : Colors.black87,
              ),
              onPressed: () {
                favoriteNotifier.toggleFavorite(pokemon.id, pokemon.name);
              },
            );
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                backgroundColor,
                Color.lerp(backgroundColor, Colors.white, 0.5)!,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Hero(
                  tag: 'pokemon-image-${pokemon.id}',
                  child: CachedNetworkImage(
                    imageUrl: info.imageUrl,
                    width: 180,
                    height: 180,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetails(
      BuildContext context, PokemonInfo info, Color primaryColor) {
    // 使用主题颜色而非硬编码白色,支持深色模式
    final cardColor = Theme.of(context).colorScheme.surface;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name and ID
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Hero(
                  tag: 'pokemon-name-${pokemon.id}',
                  child: Material(
                    color: Colors.transparent,
                    child: Text(
                      info.displayName,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Text(
                  info.idString,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Types
            Wrap(
              spacing: 8,
              children: info.types.map((type) {
                return Chip(
                  label: Text(
                    type.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  backgroundColor: type.color,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Physical Info
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    icon: Icons.straighten,
                    label: 'Height',
                    value: info.heightString,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoCard(
                    icon: Icons.fitness_center,
                    label: 'Weight',
                    value: info.weightString,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Base Stats
            const Text(
              'Base Stats',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...info.stats.map((stat) {
              return StatBar(
                label: stat.displayName,
                value: stat.baseStat,
                maxValue: stat.maxValue,
                color: primaryColor,
              );
            }),
            const SizedBox(height: 16),
            // Moves List
            MovesList(
              pokemonInfo: info,
              primaryColor: primaryColor,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}