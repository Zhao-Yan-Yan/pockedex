import 'package:flutter/material.dart';

import '../../data/models/pokemon_encounter.dart';

/// Pokemon 栖息地/出现地点组件
///
/// 展示 Pokemon 可以遇到的地点列表
class HabitatsWidget extends StatelessWidget {
  final List<LocationEncounter> encounters;
  final Color primaryColor;

  const HabitatsWidget({
    super.key,
    required this.encounters,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    if (encounters.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: primaryColor, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Habitats',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildEmptyState(),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题
        Row(
          children: [
            Icon(Icons.location_on, color: primaryColor, size: 24),
            const SizedBox(width: 8),
            const Text(
              'Habitats',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(${encounters.length})',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // 地点列表（最多显示前5个）
        ...encounters.take(5).map((encounter) {
          return _buildLocationCard(encounter);
        }),

        // 如果地点超过5个，显示"查看更多"提示
        if (encounters.length > 5)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '+${encounters.length - 5} more locations...',
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

  /// 构建地点卡片
  Widget _buildLocationCard(LocationEncounter encounter) {
    final latestVersion = encounter.latestVersion;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 地点名称
          Row(
            children: [
              Icon(
                Icons.place,
                color: primaryColor,
                size: 18,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  encounter.displayName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          if (latestVersion != null) ...[
            const SizedBox(height: 8),
            // 遇敌详情
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _buildInfoChip(
                  icon: Icons.trending_up,
                  label: '${latestVersion.maxChance}%',
                  tooltip: 'Encounter Rate',
                ),
                _buildInfoChip(
                  icon: Icons.speed,
                  label: latestVersion.levelRange,
                  tooltip: 'Level Range',
                ),
                if (latestVersion.details.isNotEmpty)
                  _buildInfoChip(
                    icon: Icons.directions_walk,
                    label: latestVersion.details.first.methodDisplay,
                    tooltip: 'Encounter Method',
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// 构建信息标签
  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: primaryColor,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 空状态视图
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 32,
            color: Colors.grey.shade400,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'This Pokémon cannot be found in the wild',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}