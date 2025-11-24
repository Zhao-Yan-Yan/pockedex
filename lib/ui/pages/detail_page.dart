import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/pokemon.dart';
import '../../data/models/pokemon_info.dart';
import '../../providers/pokemon_providers.dart';
import '../widgets/stat_bar.dart';

class DetailPage extends ConsumerWidget {
  final Pokemon pokemon;

  const DetailPage({
    super.key,
    required this.pokemon,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pokemonInfoAsync = ref.watch(pokemonInfoProvider(pokemon.name));
    final cachedColor = ref.watch(pokemonColorProvider(pokemon.id));
    final backgroundColor = cachedColor ?? Colors.grey.shade300;

    return Scaffold(
      body: pokemonInfoAsync.when(
        data: (info) => _buildContent(context, info, backgroundColor),
        loading: () => _buildLoadingContent(context, backgroundColor),
        error: (error, stack) => _buildErrorContent(context, error.toString()),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, PokemonInfo info, Color backgroundColor) {
    final lightColor = Color.lerp(backgroundColor, Colors.white, 0.3)!;

    return CustomScrollView(
      slivers: [
        _buildAppBar(context, info, lightColor),
        SliverToBoxAdapter(
          child: _buildDetails(context, info, backgroundColor),
        ),
      ],
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
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
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