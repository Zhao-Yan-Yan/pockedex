# Flutter Pokedex

一个使用 Flutter 构建的宝可梦图鉴应用，数据来源于 [PokeAPI](https://pokeapi.co/)。

采用 **Clean Architecture** 架构设计，遵循 SOLID 原则，代码结构清晰、易于维护和测试。

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

- **架构模式**: Clean Architecture (三层架构)
- **状态管理**: Riverpod (依赖注入 + 状态管理)
- **网络请求**: Dio
- **本地存储**: SQLite (sqflite)
- **图片缓存**: cached_network_image
- **颜色提取**: palette_generator

## 架构设计

本项目采用 **Clean Architecture** 架构，将代码分为三层：

```
┌─────────────────────────────────────────────┐
│  Presentation Layer (UI + State)            │
│  - UI Pages & Widgets                       │
│  - Riverpod Providers                       │
│  - 依赖 Use Cases                            │   
└──────────────────┬──────────────────────────┘
                   │ 依赖
                   ↓
┌─────────────────────────────────────────────┐
│  Domain Layer (Business Logic)              │
│  - Entities (业务实体)                       │
│  - Repository Interfaces (抽象)              │
│  - Use Cases (业务逻辑)                      │
└──────────────────┬──────────────────────────┘
                   │ 实现
                   ↓
┌─────────────────────────────────────────────┐
│  Data Layer (Data Access)                  │
│  - Repository Implementations               │
│  - Data Sources (Remote + Local)           │
│  - Models (DTO)                             │
│  - Mappers (Model ↔ Entity)                │
└─────────────────────────────────────────────┘
```

### 架构优势

1. **依赖倒置原则**: Presentation 层依赖 Domain 层抽象，不依赖 Data 层
2. **单一职责**: 每个 Use Case 只做一件事，职责清晰
3. **高度可测试**: 每一层都可以独立测试 (Mock 接口)
4. **易于维护**: 修改影响范围小，不会产生连锁反应
5. **技术无关**: Domain 层不依赖任何框架，可随时替换技术栈

## 项目结构

```
lib/
├── main.dart                          # 应用入口
│
├── domain/                            # 领域层（业务核心）
│   ├── entities/                      # 业务实体
│   │   ├── pokemon_entity.dart
│   │   └── pokemon_detail_entity.dart
│   ├── repositories/                  # Repository 抽象接口
│   │   └── pokemon_repository.dart
│   └── usecases/                      # 用例（业务逻辑）
│       ├── get_pokemon_list.dart
│       └── get_pokemon_detail.dart
│
├── data/                              # 数据层
│   ├── datasources/                   # 数据源
│   │   ├── pokemon_remote_datasource.dart      # 远程数据源接口
│   │   ├── pokemon_api_impl.dart               # API 实现
│   │   ├── pokemon_local_datasource.dart       # 本地数据源接口
│   │   └── pokemon_database_impl.dart          # 数据库实现
│   ├── models/                        # 数据传输对象 (DTO)
│   │   ├── pokemon.dart
│   │   └── pokemon_info.dart
│   ├── mappers/                       # Model <-> Entity 映射器
│   │   └── pokemon_mapper.dart
│   └── repositories/                  # Repository 实现
│       └── pokemon_repository_impl.dart
│
└── presentation/                      # 表现层
    ├── pokemon_providers.dart         # 状态管理 + 依赖注入
    └── ui/                            # UI 组件
        ├── pages/                     # 页面
        │   ├── home_page.dart
        │   └── detail_page.dart
        └── widgets/                   # 可复用组件
            ├── pokemon_card.dart
            └── stat_bar.dart
```

## 核心概念说明

### Domain Layer (领域层)

**业务核心**，不依赖任何框架：

- **Entities**: 纯业务对象，如 `PokemonEntity`
- **Repository Interfaces**: 定义数据访问的抽象接口
- **Use Cases**: 封装具体的业务逻辑，如 `GetPokemonList`

### Data Layer (数据层)

**数据访问实现**：

- **Data Sources**:
  - `RemoteDataSource` (API 网络请求)
  - `LocalDataSource` (SQLite 数据库)
- **Repository Implementation**: 实现 Domain 层的接口，协调数据源
- **Mappers**: 将 Data Model 转换为 Domain Entity

### Presentation Layer (表现层)

**UI 和状态管理**：

- **Providers**: 使用 Riverpod 进行依赖注入和状态管理
- **UI**: Flutter Widgets，通过 Providers 访问 Use Cases

## 数据流示例

```dart
// 1. UI 层调用 Use Case
final pokemonList = ref.watch(pokemonListProvider);

// 2. Provider 注入 Use Case
final getPokemonListUseCase = GetPokemonList(repository);

// 3. Use Case 调用 Repository 接口
final result = await repository.getPokemonList(page: 0);

// 4. Repository 实现协调 Data Sources
final cachedData = await localDataSource.getPokemonListByPage(page);
if (cachedData.isEmpty) {
  final remoteData = await remoteDataSource.fetchPokemonList(page);
  await localDataSource.cachePokemonList(remoteData);
}

// 5. Mapper 转换 Model -> Entity
return cachedData.map((model) => model.toEntity()).toList();
```

## 开始使用

### 环境要求

- Flutter SDK >= 3.9.2
- Dart SDK >= 3.9.2

### 安装运行

```bash
# 克隆项目
git clone https://github.com/Zhao-Yan-Yan/pockedex.git
cd ff_pockedex

# 安装依赖
flutter pub get

# 运行应用
flutter run

# 代码分析
flutter analyze
```

### 构建发布

```bash
# Android
flutter build apk

# iOS
flutter build ios

# macOS
flutter build macos
```

## 学习资源

如果你有 Android/Compose 开发背景，可以查看代码中的注释，每个文件都包含了与 Android 对应概念的对比说明。

更多架构细节，请查看 [CLEAN_ARCHITECTURE.md](./CLEAN_ARCHITECTURE.md)。

## API

本应用使用 [PokeAPI](https://pokeapi.co/) 作为数据源，这是一个免费开放的宝可梦 RESTful API。

## License

MIT License