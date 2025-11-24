import 'package:dio/dio.dart';

import '../models/pokemon.dart';
import '../models/pokemon_info.dart';

class PokemonApi {
  static const String _baseUrl = 'https://pokeapi.co/api/v2';
  static const int _pageSize = 20;

  final Dio _dio;

  PokemonApi({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: _baseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ));

  /// Fetch Pokemon list with pagination
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

  /// Fetch Pokemon details by name
  Future<PokemonInfo> fetchPokemonInfo(String name) async {
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