import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'presentation/ui/pages/home_page.dart';

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
/// StatelessWidget 是无状态组件
/// 类似 Compose 中不使用 remember 的 @Composable 函数
///
/// 对比:
/// - StatelessWidget ≈ @Composable (无状态)
/// - StatefulWidget ≈ @Composable + remember (有状态)
class PokedexApp extends StatelessWidget {
  const PokedexApp({super.key});

  /// 构建 UI
  ///
  /// MaterialApp 是 Flutter 的根 Widget
  /// 类似 Android 的 Application + Theme 配置
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokedex',
      debugShowCheckedModeBanner: false,  // 隐藏右上角的 DEBUG 标签

      // 主题配置（Material Design 3）
      // 类似 Android 的 themes.xml 或 Compose 的 MaterialTheme
      theme: ThemeData(
        // ColorScheme 类似 Android 的 color system
        // Material You 动态颜色方案
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE53935),  // 种子颜色（红色）
          brightness: Brightness.light,         // 亮色主题
        ),
        useMaterial3: true,  // 使用 Material Design 3

        // AppBar 主题配置
        appBarTheme: const AppBarTheme(
          elevation: 0,        // 无阴影（扁平化设计）
          centerTitle: false,  // 标题左对齐
        ),
      ),

      // 首页
      // 类似 Android 的 setContentView() 或 Compose 的根 Composable
      home: const HomePage(),
    );
  }
}