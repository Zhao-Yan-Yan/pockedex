import 'package:flutter/material.dart';

import '../../data/models/pokemon_info.dart';

/// Pokemon 技能列表组件
///
/// 展示 Pokemon 通过升级学会的技能列表
/// 类似 Android RecyclerView 的列表
class MovesList extends StatelessWidget {
  final PokemonInfo pokemonInfo;
  final Color primaryColor;

  const MovesList({
    super.key,
    required this.pokemonInfo,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    // 调试：打印技能数据
    print('MovesList for ${pokemonInfo.name}:');
    print('  Total moves: ${pokemonInfo.moves.length}');
    print('  Level-up moves: ${pokemonInfo.levelUpMoves.length}');
    if (pokemonInfo.moves.isNotEmpty) {
      final firstMove = pokemonInfo.moves.first;
      print('  First move: ${firstMove.name}, learn methods: ${firstMove.learnMethods.length}');
      for (var method in firstMove.learnMethods) {
        print('    - ${method.name} at level ${method.level}');
      }
    }

    // 获取按等级排序的技能列表
    final moves = pokemonInfo.levelUpMoves;

    if (moves.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          child: Row(
            children: [
              Icon(Icons.offline_bolt, color: primaryColor, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Level-Up Moves',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(${moves.length})',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // 水平滚动的技能卡片列表
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: moves.length > 10 ? 10 : moves.length,
            itemBuilder: (context, index) {
              final move = moves[index];
              final isFirst = index == 0;
              final isLast = index == (moves.length > 10 ? 9 : moves.length - 1);

              return Padding(
                padding: EdgeInsets.only(right: isLast ? 0 : 12),
                child: _buildMoveCard(move, isFirst),
              );
            },
          ),
        ),

        // 如果技能超过10个，显示"查看更多"提示
        if (moves.length > 10)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              '+${moves.length - 10} more moves...',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  /// 构建技能卡片
  Widget _buildMoveCard(move, bool isFirst) {
    return Container(
      width: 130,
      decoration: BoxDecoration(
        color: isFirst
            ? primaryColor
            : primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: isFirst
            ? null
            : Border.all(
                color: primaryColor.withValues(alpha: 0.2),
                width: 1,
              ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 等级标签
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isFirst
                    ? Colors.white.withValues(alpha: 0.25)
                    : primaryColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Lv.',
                    style: TextStyle(
                      fontSize: 10,
                      color: isFirst ? Colors.white : primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${move.learnLevel}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isFirst ? Colors.white : primaryColor,
                    ),
                  ),
                ],
              ),
            ),

            // 技能名称
            Text(
              move.displayName,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isFirst ? Colors.white : Colors.black87,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            // 首个技能标记
            if (isFirst)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'FIRST',
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              )
            else
              const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  /// 空状态视图
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.info_outline,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No level-up moves available',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}