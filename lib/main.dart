import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/theme_provider.dart';
import 'ui/pages/home_page.dart';

/// 应用入口函数
///
/// Flutter 应用的起点，类似 Android 的:
/// fun main() {
///   setContent { PokedexApp() }
/// }
void main() {
  // runApp() 启动 Flutter 应用
  // ProviderScope 是 Riverpod 的根容器
  // 类似 Compose 的 CompositionLocalProvider 或 Hilt 的入口点
  runApp(const ProviderScope(child: PokedexApp()));
}

/// 宝可梦图鉴应用根组件
///
/// ConsumerWidget 结合了 Riverpod 状态监听功能
/// 用于监听全局主题状态变化并应用主题
///
/// 对比:
/// - ConsumerWidget ≈ @Composable + collectAsState()
class PokedexApp extends ConsumerWidget {
  const PokedexApp({super.key});

  /// 构建 UI
  ///
  /// MaterialApp 是 Flutter 的根 Widget
  /// 类似 Android 的 Application + Theme 配置
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 监听主题状态变化
    // 当用户切换主题时，整个应用会自动重建并应用新主题
    final themeSettings = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Pokedex',
      debugShowCheckedModeBanner: false,  // 隐藏右上角的 DEBUG 标签

      // 应用亮色主题
      // 从 ThemeSettings 获取配置好的主题
      theme: themeSettings.getLightTheme(),

      // 应用暗色主题
      // Material Design 3 支持深色模式
      darkTheme: themeSettings.getDarkTheme(),

      // 主题模式（浅色/深色/跟随系统）
      // 类似 Android 的 AppCompatDelegate.setDefaultNightMode()
      themeMode: themeSettings.themeMode,

      // 首页
      // 类似 Android 的 setContentView() 或 Compose 的根 Composable
      home: const HomePage(),
    );
  }
}