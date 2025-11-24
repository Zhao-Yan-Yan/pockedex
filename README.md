# Flutter Pokedex

一个使用 Flutter 构建的宝可梦图鉴应用，数据来源于 [PokeAPI](https://pokeapi.co/)。

## 功能特性

- 宝可梦列表展示（2列网格布局）
- 无限滚动分页加载
- 下拉刷新
- 宝可梦详情页（类型、身高、体重、能力值）
- 从宝可梦图片提取主色调作为卡片背景
- Hero 共享元素转场动画
- 本地 SQLite 缓存，支持离线查看
- 能力值进度条动画

## 技术栈

- **状态管理**: Riverpod
- **网络请求**: Dio
- **本地存储**: SQLite (sqflite)
- **图片缓存**: cached_network_image
- **颜色提取**: palette_generator

## 项目结构

```
lib/
├── main.dart                 # 应用入口
├── data/
│   ├── api/                  # 网络请求层
│   ├── database/             # 本地数据库
│   ├── models/               # 数据模型
│   └── repository/           # 数据仓库
├── providers/                # Riverpod 状态管理
└── ui/
    ├── pages/                # 页面
    └── widgets/              # 可复用组件
```

## 开始使用

### 环境要求

- Flutter SDK >= 3.9.2
- Dart SDK >= 3.9.2

### 安装运行

```bash
# 克隆项目
git clone https://github.com/your-username/ff_pockedex.git
cd ff_pockedex

# 安装依赖
flutter pub get

# 运行应用
flutter run
```

### 构建发布

```bash
# Android
flutter build apk

# iOS
flutter build ios
```

## API

本应用使用 [PokeAPI](https://pokeapi.co/) 作为数据源，这是一个免费开放的宝可梦 RESTful API。

## License

MIT License