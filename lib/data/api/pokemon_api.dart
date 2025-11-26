import 'package:dio/dio.dart';

import '../models/pokemon.dart';
import '../models/pokemon_info.dart';

/// Pokemon API 网络请求层
///
/// 对应 Android 中的 Retrofit Service 接口
/// 使用 Dio (类似 Retrofit) 进行网络请求
class PokemonApi {
  static const String _baseUrl = 'https://pokeapi.co/api/v2';
  static const int _pageSize = 20;  // 每页加载 20 条数据

  final Dio _dio;  // Dio 客户端（类似 OkHttpClient + Retrofit）

  /// 构造函数，支持依赖注入（便于测试）
  ///
  /// 类似 Retrofit.Builder() 配置
  /// [dio] 可选的 Dio 实例，主要用于测试时注入 Mock
  PokemonApi({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: _baseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ));

  /// 获取 Pokemon 列表（分页）
  ///
  /// [page] 页码，从 0 开始
  /// 返回包含分页信息的响应对象
  ///
  /// 类似 Retrofit 的 @GET("/pokemon")
  Future<PokemonListResponse> fetchPokemonList({int page = 0}) async {
    try {
      final offset = page * _pageSize;
      final response = await _dio.get(
        '/pokemon',
        queryParameters: {
          'limit': _pageSize,
          'offset': offset,
        },
      );
      return PokemonListResponse.fromJson(
        response.data as Map<String, dynamic>,
        page,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 根据名称获取 Pokemon 详细信息
  ///
  /// [name] Pokemon 名称（小写，如 "pikachu"）
  /// 返回详细的宝可梦信息（包含属性、能力值等）
  ///
  /// 类似 Retrofit 的 @GET("/pokemon/{name}")
  Future<PokemonInfo> fetchPokemonInfo(String name) async {
    try {
      final response = await _dio.get('/pokemon/$name');
      return PokemonInfo.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 处理网络错误，转换为用户友好的异常
  ///
  /// 将 Dio 的底层异常转换为业务异常
  /// 类似 Retrofit 的 ErrorHandler 或 Interceptor
  Exception _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException('请求超时，请重试');
      case DioExceptionType.connectionError:
        return NetworkException('网络连接失败，请检查网络设置');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 404) {
          return NotFoundException('找不到请求的资源');
        }
        return ServerException('服务器开小差了，请稍后重试');
      default:
        return ApiException('数据加载失败');
    }
  }
}

// ==================== 自定义异常类 ====================
// 类似 Android 中的自定义 Exception，用于区分不同错误类型

/// API 基础异常类
class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

/// 网络连接异常
class NetworkException extends ApiException {
  NetworkException(super.message);
}

/// 请求超时异常
class TimeoutException extends ApiException {
  TimeoutException(super.message);
}

/// 服务器错误异常
class ServerException extends ApiException {
  ServerException(super.message);
}

/// 资源未找到异常 (404)
class NotFoundException extends ApiException {
  NotFoundException(super.message);
}