import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/pokemon.dart';
import '../../providers/pokemon_providers.dart';
import '../widgets/pokemon_card.dart';
import 'detail_page.dart';

/// 收藏列表页面
///
/// 功能:
/// 1. 显示所有收藏的 Pokemon
/// 2. 支持点击查看详情
/// 3. 空状态提示
/// 4. 下拉刷新
///
/// 类似 Android 中的 FavoritesActivity 或 FavoritesFragment
class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 监听收藏状态
    final favoriteState = ref.watch(favoriteProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
        actions: [
          // 显示收藏数量
          if (favoriteState.favorites.isNotEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  '${favoriteState.favorites.length}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: favoriteState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : favoriteState.favorites.isEmpty
              ? _buildEmptyState(context)
              : _buildFavoriteList(context, ref, favoriteState.favorites),
    );
  }

  /// 空状态视图
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No Favorites Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start adding your favorite Pokemon!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  /// 收藏列表
  Widget _buildFavoriteList(
    BuildContext context,
    WidgetRef ref,
    List<Pokemon> favorites,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        // 下拉刷新收藏列表
        await ref.read(favoriteProvider.notifier).loadFavorites();
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final pokemon = favorites[index];
            return PokemonCard(
              pokemon: pokemon,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => DetailPage(pokemon: pokemon),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}