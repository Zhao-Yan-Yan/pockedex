import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/theme_provider.dart';

/// 主题选择器弹窗
///
/// 显示主题颜色和暗黑模式选择界面
/// 类似 Android 的 BottomSheetDialog 或 Compose ModalBottomSheet
class ThemeSelectorSheet extends ConsumerWidget {
  const ThemeSelectorSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSettings = ref.watch(themeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Text(
              '主题设置',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(height: 16),

          // 暗黑模式切换
          _buildDarkModeSection(context, ref, themeSettings, isDark),
          const SizedBox(height: 24),

          // 主题颜色选择
          _buildColorSection(context, ref, themeSettings),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// 构建暗黑模式切换区域
  Widget _buildDarkModeSection(
    BuildContext context,
    WidgetRef ref,
    ThemeSettings settings,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            '外观模式',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        const SizedBox(height: 12),
        // 三种模式选项（跟随系统/浅色/深色）
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildThemeModeChip(
                context,
                ref,
                '跟随系统',
                Icons.brightness_auto,
                ThemeMode.system,
                settings.themeMode == ThemeMode.system,
              ),
              const SizedBox(width: 8),
              _buildThemeModeChip(
                context,
                ref,
                '浅色',
                Icons.light_mode,
                ThemeMode.light,
                settings.themeMode == ThemeMode.light,
              ),
              const SizedBox(width: 8),
              _buildThemeModeChip(
                context,
                ref,
                '深色',
                Icons.dark_mode,
                ThemeMode.dark,
                settings.themeMode == ThemeMode.dark,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建主题模式选择 Chip
  Widget _buildThemeModeChip(
    BuildContext context,
    WidgetRef ref,
    String label,
    IconData icon,
    ThemeMode mode,
    bool isSelected,
  ) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          ref.read(themeProvider.notifier).setThemeMode(mode);
        }
      },
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      checkmarkColor: Theme.of(context).colorScheme.primary,
    );
  }

  /// 构建主题颜色选择区域
  Widget _buildColorSection(
    BuildContext context,
    WidgetRef ref,
    ThemeSettings settings,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            '主题颜色',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        const SizedBox(height: 12),
        // 颜色网格
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: AppThemeColor.values.map((themeColor) {
            final isSelected = settings.themeColor == themeColor;
            return _buildColorOption(
              context,
              ref,
              themeColor,
              isSelected,
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 构建单个颜色选项
  Widget _buildColorOption(
    BuildContext context,
    WidgetRef ref,
    AppThemeColor themeColor,
    bool isSelected,
  ) {
    return InkWell(
      onTap: () {
        ref.read(themeProvider.notifier).setThemeColor(themeColor);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 72,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? themeColor.color.withValues(alpha: 0.15)
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? themeColor.color
                : Theme.of(context).dividerColor,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 颜色圆圈
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: themeColor.color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: themeColor.color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 20,
                    )
                  : null,
            ),
            const SizedBox(height: 8),
            // 颜色标签
            Text(
              themeColor.label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? themeColor.color : null,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// 显示主题选择器的辅助函数
///
/// 弹出底部弹窗供用户选择主题
/// 类似 Android 的 showModalBottomSheet
void showThemeSelector(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const ThemeSelectorSheet(),
  );
}