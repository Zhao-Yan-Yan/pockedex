# Clean Architecture 重构说明

## 📁 新的项目结构

```
lib/
├── domain/                          # 领域层（业务核心）
│   ├── entities/                    # 业务实体
│   │   ├── pokemon_entity.dart
│   │   └── pokemon_detail_entity.dart
│   ├── repositories/                # Repository 抽象接口
│   │   └── pokemon_repository.dart
│   └── usecases/                    # 用例（业务逻辑）
│       ├── get_pokemon_list.dart
│       └── get_pokemon_detail.dart
│
├── data/                            # 数据层
│   ├── datasources/                 # 数据源
│   │   ├── pokemon_remote_datasource.dart        # 远程数据源接口
│   │   ├── pokemon_api_impl.dart                 # 远程数据源实现
│   │   ├── pokemon_local_datasource.dart         # 本地数据源接口
│   │   └── pokemon_database_impl.dart            # 本地数据源实现
│   ├── models/                      # 数据传输对象 (DTO)
│   │   ├── pokemon.dart
│   │   └── pokemon_info.dart
│   ├── mappers/                     # Model <-> Entity 映射器
│   │   └── pokemon_mapper.dart
│   └── repositories/                # Repository 实现
│       └── pokemon_repository_impl.dart
│
└── presentation/                    # 表现层
    ├── pokemon_providers.dart       # 状态管理 (Riverpod)
    └── ui/                          # UI 组件
        ├── pages/
        └── widgets/
```

## 🔄 依赖关系图

```
┌─────────────────────────────────────────────┐
│  Presentation Layer (UI + Providers)        │
│  - 使用 Use Cases                            │
│  - 不直接访问 Repository                      │
└──────────────────┬──────────────────────────┘
                   │ 依赖
                   ↓
┌─────────────────────────────────────────────┐
│  Domain Layer (Business Logic)              │
│  - Entities (业务实体)                        │
│  - Repository Interfaces (抽象)              │
│  - Use Cases (业务逻辑)                       │
└──────────────────┬──────────────────────────┘
                   │ 实现
                   ↓
┌─────────────────────────────────────────────┐
│  Data Layer (Data Access)                   │
│  - Repository Implementations                │
│  - Data Sources (Remote + Local)            │
│  - Models (DTO)                              │
│  - Mappers                                   │
└─────────────────────────────────────────────┘
```

## ✅ Clean Architecture 原则实现

### 1. 依赖倒置原则 (Dependency Inversion)
- ✅ Domain 层定义接口 (`PokemonRepository`)
- ✅ Data 层实现接口 (`PokemonRepositoryImpl`)
- ✅ Presentation 层依赖 Domain 层，不依赖 Data 层

### 2. 单一职责原则 (Single Responsibility)
- ✅ **Use Cases**: 每个用例只做一件事
  - `GetPokemonList`: 获取列表
  - `GetPokemonDetail`: 获取详情
- ✅ **Repository**: 只负责数据协调
- ✅ **Data Sources**: Remote 负责网络，Local 负责缓存

### 3. 开闭原则 (Open/Closed)
- ✅ 通过接口扩展，不修改现有代码
- ✅ 可以轻松替换数据源实现（如从 SQLite 换成 Hive）

### 4. 接口隔离原则 (Interface Segregation)
- ✅ `RemoteDataSource` 和 `LocalDataSource` 分离
- ✅ 各接口只包含必要的方法

### 5. 里氏替换原则 (Liskov Substitution)
- ✅ 所有实现都可以替换其接口
- ✅ 便于单元测试（Mock 接口）

## 🔧 下一步工作

### 待完成的重构:

1. **更新 Presentation 层**
   ```dart
   // 旧代码 (直接使用 Repository)
   final pokemonList = await repository.fetchPokemonList(page: 0);

   // 新代码 (使用 Use Case)
   final getPokemonList = GetPokemonList(repository);
   final pokemonList = await getPokemonList(Params(page: 0));
   ```

2. **配置依赖注入**
   ```dart
   // 在 providers 中配置所有依赖
   final remoteDataSourceProvider = Provider<PokemonRemoteDataSource>(...);
   final localDataSourceProvider = Provider<PokemonLocalDataSource>(...);
   final repositoryProvider = Provider<PokemonRepository>(...);
   final getPokemonListProvider = Provider<GetPokemonList>(...);
   ```

3. **修复导入路径**
   - 所有文件的 import 语句需要更新
   - `lib/ui/` → `lib/presentation/ui/`
   - `lib/providers/` → `lib/presentation/`

4. **更新 main.dart**
   ```dart
   import 'presentation/ui/pages/home_page.dart';
   ```

## 📊 对比: 旧架构 vs Clean Architecture

| 方面 | 旧架构 | Clean Architecture |
|------|--------|-------------------|
| **层数** | 2层 | 3层 |
| **业务逻辑** | 分散在 Providers | 集中在 Use Cases |
| **依赖方向** | UI → Repository | UI → Use Cases → Repository Interface |
| **可测试性** | 中等 | 优秀 (接口 Mock) |
| **可维护性** | 中等 | 优秀 (职责清晰) |
| **复杂度** | 简单 | 较复杂 |
| **适用场景** | 小型项目 | 中大型项目 |

## 🎯 优势

1. **高度可测试**: 每一层都可以独立测试
2. **易于维护**: 职责清晰，修改影响范围小
3. **可扩展**: 易于添加新功能，不影响现有代码
4. **技术无关**: Domain 层不依赖任何框架
5. **团队协作**: 不同层可以并行开发

## ⚠️ 注意事项

由于项目已经部分重构完成，需要注意:

1. **文件位置变化**:
   - `lib/ui/` → `lib/presentation/ui/`
   - `lib/providers/` → `lib/presentation/`

2. **新增文件**:
   - `domain/` 下的所有文件
   - `data/mappers/` 和 `data/datasources/` 的新文件

3. **需要完成的工作**:
   - 更新所有 import 语句
   - 重构 Providers 使用 Use Cases
   - 配置依赖注入
   - 测试所有功能

## 📖 学习资源

- [The Clean Architecture by Uncle Bob](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Clean Architecture by Reso Coder](https://resocoder.com/flutter-clean-architecture-tdd/)
- [Android Clean Architecture](https://developer.android.com/topic/architecture)