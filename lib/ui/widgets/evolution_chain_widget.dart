import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../data/models/evolution_chain.dart';

/// Pokemon 进化链可视化组件
///
/// 横向滚动展示 Pokemon 的进化路径
class EvolutionChainWidget extends StatelessWidget {
  final EvolutionChain evolutionChain;
  final Color primaryColor;

  const EvolutionChainWidget({
    super.key,
    required this.evolutionChain,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    // 获取扁平化的进化链
    final flatChain = evolutionChain.flatChain;

    if (flatChain.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题
        Row(
          children: [
            Icon(Icons.auto_awesome, color: primaryColor, size: 24),
            const SizedBox(width: 8),
            const Text(
              'Evolution Chain',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // 进化链水平滚动列表
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: flatChain.length,
            separatorBuilder: (context, index) {
              // 显示下一个 Pokemon 的进化条件
              // index + 1 表示箭头指向的下一个进化形态
              return _buildArrow(flatChain[index + 1]);
            },
            itemBuilder: (context, index) {
              return _buildEvolutionCard(flatChain[index], index == 0);
            },
          ),
        ),
      ],
    );
  }

  /// 构建进化箭头和条件
  Widget _buildArrow(ChainLink link) {
    // 如果没有进化条件，说明是起始形态，不需要箭头
    if (link.evolutionDetails.isEmpty) {
      return const SizedBox.shrink();
    }

    final condition = link.evolutionDetails.first.description;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.arrow_forward,
            color: primaryColor,
            size: 28,
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: primaryColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Text(
              condition,
              style: TextStyle(
                fontSize: 11,
                color: primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建进化阶段卡片
  Widget _buildEvolutionCard(ChainLink link, bool isFirst) {
    return Container(
      width: 110,
      decoration: BoxDecoration(
        color: isFirst
            ? primaryColor.withValues(alpha: 0.12)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFirst
              ? primaryColor.withValues(alpha: 0.3)
              : Colors.grey.shade300,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Pokemon 图片
          CachedNetworkImage(
            imageUrl: link.imageUrl,
            width: 70,
            height: 70,
            fit: BoxFit.contain,
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => Icon(
              Icons.catching_pokemon,
              size: 70,
              color: Colors.grey.shade400,
            ),
          ),

          const SizedBox(height: 8),

          // Pokemon 名称
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              link.displayName,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isFirst ? FontWeight.bold : FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // ID
          Text(
            '#${link.speciesId.toString().padLeft(3, '0')}',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),

          // 幼年形态标记
          if (link.isBaby)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.pink.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'BABY',
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.pink.shade700,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}