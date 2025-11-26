import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palette_generator/palette_generator.dart';

import '../../data/models/pokemon.dart';
import '../../providers/pokemon_providers.dart';

/// Pokemon 卡片组件（网格列表项）
///
/// 功能:
/// 1. 显示 Pokemon 图片和名称
/// 2. 从图片中提取主色调作为背景色（动态主题）
/// 3. Hero 动画支持（共享元素转场）
/// 4. 点击跳转到详情页
///
/// ConsumerStatefulWidget 是 Riverpod 的特殊 Widget
/// 结合了 StatefulWidget + Provider 监听能力
///
/// 类似 Compose 中的:
/// @Composable
/// fun PokemonCard(pokemon: Pokemon, onClick: () -> Unit) {
///   val color by remember { mutableStateOf<Color?>(null) }
///   LaunchedEffect(pokemon) { color = extractColorFromImage(...) }
///   Card(modifier = Modifier.clickable(onClick)) { ... }
/// }
class PokemonCard extends ConsumerStatefulWidget {
  final Pokemon pokemon;        // Pokemon 数据
  final VoidCallback onTap;     // 点击回调

  const PokemonCard({
    super.key,
    required this.pokemon,
    required this.onTap,
  });

  @override
  ConsumerState<PokemonCard> createState() => _PokemonCardState();
}

/// PokemonCard 的状态类
///
/// ConsumerState 可以通过 ref 访问 Riverpod Provider
/// 类似 Compose 中可以直接访问 ViewModel
class _PokemonCardState extends ConsumerState<PokemonCard> {
  Color? _dominantColor;  // 从图片提取的主色调

  @override
  void initState() {
    super.initState();
    _extractColor();  // 初始化时提取颜色
  }

  /// 从 Pokemon 图片中提取主色调
  ///
  /// 实现动态主题效果（Material You 风格）
  /// 类似 Android 12+ 的 Dynamic Color
  ///
  /// 流程:
  /// 1. 先查缓存（避免重复计算）
  /// 2. 使用 PaletteGenerator 提取颜色
  /// 3. 缓存颜色到 Provider
  /// 4. 更新 UI
  Future<void> _extractColor() async {
    // 第一步: 检查缓存
    // ref.read() 类似一次性读取，不会监听变化
    final cachedColor = ref.read(pokemonColorProvider(widget.pokemon.id));
    if (cachedColor != null) {
      setState(() {
        _dominantColor = cachedColor;
      });
      return;
    }

    try {
      // 第二步: 从图片提取颜色
      // 类似 Android Palette API: Palette.from(bitmap).generate()
      final paletteGenerator = await PaletteGenerator.fromImageProvider(
        CachedNetworkImageProvider(widget.pokemon.imageUrl),
        size: const Size(120, 120),  // 缩小尺寸加速计算
        maximumColorCount: 20,       // 最多提取 20 种颜色
      );

      // 优先使用主色调，备选浅色
      final color = paletteGenerator.dominantColor?.color ??
          paletteGenerator.lightMutedColor?.color ??
          Colors.grey.shade200;

      // 第三步: 缓存颜色（下次直接使用）
      ref.read(pokemonColorProvider(widget.pokemon.id).notifier).state = color;

      // 第四步: 更新 UI
      // mounted 检查防止异步回调时 Widget 已销毁
      // 类似 Compose 中不需要手动检查，协程作用域会自动管理
      if (mounted) {
        setState(() {
          _dominantColor = color;
        });
      }
    } catch (e) {
      // 错误处理：使用默认灰色
      if (mounted) {
        setState(() {
          _dominantColor = Colors.grey.shade200;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 计算背景色：使用提取的主色调，混合 30% 白色使其更柔和
    final backgroundColor = _dominantColor ?? Colors.grey.shade200;
    final lightBackground = Color.lerp(backgroundColor, Colors.white, 0.3)!;

    // GestureDetector 类似 Modifier.clickable
    return GestureDetector(
      onTap: widget.onTap,
      // AnimatedContainer 会自动对属性变化应用动画
      // 类似 Compose 的 animateContentSize() + animateColorAsState()
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: lightBackground,
          borderRadius: BorderRadius.circular(14),
          // 添加阴影（Material Design 风格）
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        // Column 类似 Compose 的 Column
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Hero 动画：共享元素转场
            // 类似 Android Shared Element Transition
            // 或 Compose 的 SharedTransitionLayout
            //
            // 原理：
            // 1. 列表页和详情页有相同 tag 的 Hero Widget
            // 2. 页面切换时，Flutter 会自动将图片从列表位置动画到详情页位置
            Hero(
              tag: 'pokemon-image-${widget.pokemon.id}',  // 唯一标识
              // CachedNetworkImage: 网络图片缓存库
              // 类似 Android 的 Glide/Coil
              child: CachedNetworkImage(
                imageUrl: widget.pokemon.imageUrl,
                width: 120,
                height: 120,
                fit: BoxFit.contain,  // 类似 Android ScaleType.FIT_CENTER
                // 加载中占位
                placeholder: (context, url) => const SizedBox(
                  width: 120,
                  height: 120,
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                // 加载失败占位
                errorWidget: (context, url, error) => const SizedBox(
                  width: 120,
                  height: 120,
                  child: Icon(Icons.error_outline, size: 40),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Pokemon 名称也参与 Hero 动画
            Hero(
              tag: 'pokemon-name-${widget.pokemon.id}',
              // Material Widget 用于保持文本样式在动画中的一致性
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