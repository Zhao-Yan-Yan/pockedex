import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ==================== 主题配置 ====================

/// 预设主题颜色
///
/// 提供多种主题色方案供用户选择
/// 类似 Material You 的动态颜色系统
enum AppThemeColor {
  red('红色', Color(0xFFE53935)),
  blue('蓝色', Color(0xFF1E88E5)),
  green('绿色', Color(0xFF43A047)),
  purple('紫色', Color(0xFF8E24AA)),
  orange('橙色', Color(0xFFFB8C00)),
  teal('青色', Color(0xFF00897B)),
  pink('粉色', Color(0xFFE91E63)),
  indigo('靛蓝', Color(0xFF3949AB));

  const AppThemeColor(this.label, this.color);

  final String label;
  final Color color;
}

/// 主题设置状态
///
/// 管理用户的主题偏好（颜色 + 暗黑模式）
/// 类似 Android 的 UiState data class
class ThemeSettings {
  final AppThemeColor themeColor;
  final ThemeMode themeMode;

  const ThemeSettings({
    this.themeColor = AppThemeColor.red,
    this.themeMode = ThemeMode.system,
  });

  ThemeSettings copyWith({
    AppThemeColor? themeColor,
    ThemeMode? themeMode,
  }) {
    return ThemeSettings(
      themeColor: themeColor ?? this.themeColor,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  /// 获取亮色主题
  ThemeData getLightTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: themeColor.color,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
      ),
    );
  }

  /// 获取暗色主题
  ThemeData getDarkTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: themeColor.color,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
      ),
    );
  }
}

// ==================== 主题状态管理 ====================

/// 主题设置 StateNotifier
///
/// 管理主题配置的状态变化
/// 类似 Android ViewModel
class ThemeNotifier extends StateNotifier<ThemeSettings> {
  ThemeNotifier() : super(const ThemeSettings());

  /// 切换主题颜色
  void setThemeColor(AppThemeColor color) {
    state = state.copyWith(themeColor: color);
  }

  /// 切换主题模式（浅色/深色/跟随系统）
  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
  }

  /// 快速切换浅色/深色模式
  void toggleDarkMode() {
    if (state.themeMode == ThemeMode.dark) {
      state = state.copyWith(themeMode: ThemeMode.light);
    } else {
      state = state.copyWith(themeMode: ThemeMode.dark);
    }
  }
}

/// 主题设置 Provider
///
/// 全局主题状态管理
/// UI 通过 ref.watch(themeProvider) 监听主题变化
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeSettings>((ref) {
  return ThemeNotifier();
});