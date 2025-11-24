import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palette_generator/palette_generator.dart';

import '../../data/models/pokemon.dart';
import '../../providers/pokemon_providers.dart';

class PokemonCard extends ConsumerStatefulWidget {
  final Pokemon pokemon;
  final VoidCallback onTap;

  const PokemonCard({
    super.key,
    required this.pokemon,
    required this.onTap,
  });

  @override
  ConsumerState<PokemonCard> createState() => _PokemonCardState();
}

class _PokemonCardState extends ConsumerState<PokemonCard> {
  Color? _dominantColor;

  @override
  void initState() {
    super.initState();
    _extractColor();
  }

  Future<void> _extractColor() async {
    // Check if color is already cached
    final cachedColor = ref.read(pokemonColorProvider(widget.pokemon.id));
    if (cachedColor != null) {
      setState(() {
        _dominantColor = cachedColor;
      });
      return;
    }

    try {
      final paletteGenerator = await PaletteGenerator.fromImageProvider(
        CachedNetworkImageProvider(widget.pokemon.imageUrl),
        size: const Size(120, 120),
        maximumColorCount: 20,
      );

      final color = paletteGenerator.dominantColor?.color ??
          paletteGenerator.lightMutedColor?.color ??
          Colors.grey.shade200;

      // Cache the color
      ref.read(pokemonColorProvider(widget.pokemon.id).notifier).state = color;

      if (mounted) {
        setState(() {
          _dominantColor = color;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _dominantColor = Colors.grey.shade200;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _dominantColor ?? Colors.grey.shade200;
    final lightBackground = Color.lerp(backgroundColor, Colors.white, 0.3)!;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: lightBackground,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'pokemon-image-${widget.pokemon.id}',
              child: CachedNetworkImage(
                imageUrl: widget.pokemon.imageUrl,
                width: 120,
                height: 120,
                fit: BoxFit.contain,
                placeholder: (context, url) => const SizedBox(
                  width: 120,
                  height: 120,
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (context, url, error) => const SizedBox(
                  width: 120,
                  height: 120,
                  child: Icon(Icons.error_outline, size: 40),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Hero(
              tag: 'pokemon-name-${widget.pokemon.id}',
              child: Material(
                color: Colors.transparent,
                child: Text(
                  widget.pokemon.displayName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}