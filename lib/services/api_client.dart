import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_config.dart';
import 'api_exception.dart';

/// 全局 HTTP 客户端封装，基于 [Dio]。
///
/// 约定：只有 `lib/services/` 下的 repository 持有它；
/// 页面与 `AppState` 通过 repository 取数据，不直接发起请求。
///
/// 用法示例：
/// ```dart
/// final client = ApiClient();
/// client.setToken(token);
/// final json = await client.getJson('/feed', query: {'page': 1});
/// ```
class ApiClient {
  ApiClient({Dio? dio, String? baseUrl}) : _dio = dio ?? Dio() {
    _dio.options = BaseOptions(
      baseUrl: baseUrl ?? ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      headers: <String, dynamic>{
        Headers.acceptHeader: Headers.jsonContentType,
        Headers.contentTypeHeader: Headers.jsonContentType,
      },
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
          final token = _token;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true),
      );
    }
  }

  final Dio _dio;
  String? _token;

  /// 登录成功后写入 token，后续请求会自动带上 `Authorization` 头。
  void setToken(String? token) {
    _token = token;
  }

  /// 发送 GET 请求并返回 JSON 对象。
  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, dynamic>? query,
  }) {
    return _send('GET', path, query: query);
  }

  /// 发送 POST 请求并返回 JSON 对象。
  Future<Map<String, dynamic>> postJson(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
  }) {
    return _send('POST', path, body: body, query: query);
  }

  /// 关闭连接池，一般只在测试或登出销毁时调用。
  void close() {
    _dio.close(force: true);
  }

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, dynamic>? query,
    Object? body,
  }) async {
    try {
      final response = await _dio.request<Object?>(
        path,
        data: body,
        queryParameters: query,
        options: Options(method: method),
      );
      return _asJsonMap(response.data);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  static Map<String, dynamic> _asJsonMap(Object? data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return <String, dynamic>{'data': data};
  }
}
