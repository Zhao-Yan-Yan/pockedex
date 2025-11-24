# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 常用命令

```bash
flutter pub get          # 安装依赖
flutter analyze          # 静态代码分析
flutter test             # 运行所有测试
flutter test test/widget_test.dart  # 运行单个测试文件
flutter run              # 在设备/模拟器上运行
flutter build apk        # 构建 Android APK
flutter build ios        # 构建 iOS 应用
```

## 架构说明

这是一个宝可梦图鉴应用，采用分层架构，使用 Riverpod 进行状态管理。

### 数据层 (`lib/data/`)
- **api/**: 网络层，使用 Dio 客户端，从 PokeAPI (`https://pokeapi.co/api/v2`) 获取数据
- **database/**: SQLite 持久化层，用于离线缓存
- **models/**: 数据模型（`Pokemon` 列表项，`PokemonInfo` 详情）
- **repository/**: 整合 API 和数据库，实现缓存优先策略

### 状态管理 (`lib/providers/`)
使用 Riverpod 的 `StateNotifier` 模式：
- `pokemonListProvider`: 管理分页列表，支持加载更多
- `pokemonInfoProvider`: Family provider，获取单个宝可梦详情
- `pokemonColorProvider`: 缓存从图片提取的主色调

### UI 层 (`lib/ui/`)
- **pages/**: `HomePage`（网格列表带分页）和 `DetailPage`（宝可梦详情与能力值）
- **widgets/**: 可复用组件（`PokemonCard` 带颜色提取，`StatBar` 带动画）

### 核心模式
- 缓存优先：先查本地数据库，无数据再请求网络
- 颜色提取：使用 `palette_generator` 从宝可梦图片提取主色调实现动态主题
- Hero 动画：列表页和详情页之间的共享元素转场
- 下拉刷新：通过 `forceRefresh` 参数绕过缓存强制刷新