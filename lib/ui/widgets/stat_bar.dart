import 'package:flutter/material.dart';

/// 能力值进度条组件（带动画效果）
///
/// 用于显示 Pokemon 的各项能力值（HP、攻击、防御等）
///
/// Flutter 中的 Widget 对应:
/// - StatefulWidget ≈ Compose 中的 remember + mutableStateOf
/// - 有内部状态需要管理时使用 StatefulWidget
///
/// 类似 Compose 中的:
/// @Composable
/// fun StatBar(label: String, value: Int, maxValue: Int, color: Color) {
///   val animatedValue by animateFloatAsState(...)
///   Row { ... }
/// }
class StatBar extends StatefulWidget {
  final String label;              // 能力值标签（如 "HP", "ATK"）
  final int value;                 // 当前值
  final int maxValue;              // 最大值（用于计算百分比）
  final Color color;               // 进度条颜色
  final Duration animationDuration; // 动画时长

  const StatBar({
    super.key,
    required this.label,
    required this.value,
    required this.maxValue,
    required this.color,
    this.animationDuration = const Duration(milliseconds: 950),
  });

  @override
  State<StatBar> createState() => _StatBarState();
}

/// StatBar 的私有状态类
///
/// SingleTickerProviderStateMixin 用于动画
/// 类似 Android 中的 ValueAnimator
class _StatBarState extends State<StatBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;  // 动画控制器（0.0 -> 1.0）
  late Animation<double> _animation;     // 动画值（应用缓动曲线后）

  @override
  void initState() {
    super.initState();
    // 初始化动画控制器
    // 类似 Android 的 ValueAnimator.ofFloat(0f, 1f).setDuration(950)
    _controller = AnimationController(
      vsync: this,  // vsync 用于屏幕刷新同步，避免资源浪费
      duration: widget.animationDuration,
    );

    // 应用缓动曲线（类似 Android 的 Interpolator）
    // Curves.easeOut 类似 DecelerateInterpolator
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    // 启动动画（从 0.0 到 1.0）
    _controller.forward();
  }

  @override
  void dispose() {
    // 释放动画资源（必须！）
    // 类似 Android View 的 onDetachedFromWindow
    _controller.dispose();
    super.dispose();
  }

  /// 构建 UI
  ///
  /// Flutter 中 build 方法类似 Compose 中的 @Composable 函数
  /// 每次状态改变时都会重新执行（但 Flutter 会做 diff 优化）
  @override
  Widget build(BuildContext context) {
    final percentage = widget.value / widget.maxValue;  // 计算百分比

    // Row 类似 Compose 的 Row
    // Padding 类似 Modifier.padding()
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // 标签部分（固定宽度）
          // SizedBox 类似 Spacer 或固定 size 的 Box
          SizedBox(
            width: 50,
            child: Text(
              widget.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          const SizedBox(width: 8),  // 间距，类似 Spacer(8.dp)

          // 数值部分（带动画）
          SizedBox(
            width: 40,
            child: AnimatedBuilder(
              // AnimatedBuilder 类似 Compose 的 animateFloatAsState
              // 当 _animation 变化时自动重建 UI
              animation: _animation,
              builder: (context, child) {
                return Text(
                  '${(widget.value * _animation.value).round()}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 8),

          // 进度条部分（可扩展）
          // Expanded 类似 Modifier.weight(1f)
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  // LinearProgressIndicator 类似 Android 的 ProgressBar
                  return LinearProgressIndicator(
                    value: percentage * _animation.value,  // 动画进度
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(widget.color),
                    minHeight: 8,
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 8),

          // 最大值显示
          SizedBox(
            width: 35,
            child: Text(
              '${widget.maxValue}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}