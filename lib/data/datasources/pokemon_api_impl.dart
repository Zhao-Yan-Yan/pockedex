import 'package:dio/dio.dart';

import '../models/pokemon.dart';
import '../models/pokemon_info.dart';
import 'pokemon_remote_datasource.dart';

/// Pokemon 远程数据源实现 (使用 Dio)
///
/// 实现 PokemonRemoteDataSource 接口
/// 负责网络请求的具体实现
///
/// 类似 Android Retrofit Service 的实现类
class PokemonRemoteDataSourceImpl implements PokemonRemoteDataSource {
  static const String _baseUrl = 'https://pokeapi.co/api/v2';
  static const int _pageSize = 20;

  final Dio _dio;

  PokemonRemoteDataSourceImpl({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: _baseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ));

  @override
  Future<PokemonListResponse> fetchPokemonList(int page) async {
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

  @override
  Future<PokemonInfo> fetchPokemonDetail(String name) async {
    try {
      final response = await _dio.get('/pokemon/$name');
      return PokemonInfo.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException('请求超时，请检查网络连接');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 404) {
          return NotFoundException('请求的资源不存在');
        }
        return ServerException('服务器错误: $statusCode');
      case DioExceptionType.connectionError:
        return NetworkException('网络连接失败，请检查网络设置');
      default:
        return ApiException('请求失败: ${e.message}');
    }
  }
}

// 异常类定义
class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  NetworkException(super.message);
}

class TimeoutException extends ApiException {
  TimeoutException(super.message);
}

class ServerException extends ApiException {
  ServerException(super.message);
}

class NotFoundException extends ApiException {
  NotFoundException(super.message);
}