import 'package:dio/dio.dart';

/// 数据层统一抛出的网络异常。
///
/// 页面只需要提示 [message]，无需关心 Dio 的具体错误类型。
class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode, this.cause});

  /// 把 Dio 的异常转换为带中文提示的 [ApiException]。
  factory ApiException.fromDio(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return ApiException('请求超时，请稍后重试。', cause: error);
    }
    if (error.type == DioExceptionType.connectionError) {
      return ApiException('无法连接服务器，请检查网络。', cause: error);
    }
    if (error.type == DioExceptionType.badResponse) {
      final status = error.response?.statusCode;
      final serverMessage = _serverMessage(error.response?.data);
      return ApiException(
        serverMessage ?? '服务器返回错误${status == null ? '' : '（$status）'}。',
        statusCode: status,
        cause: error,
      );
    }
    if (error.type == DioExceptionType.cancel) {
      return ApiException('请求已取消。', cause: error);
    }
    if (error.type == DioExceptionType.badCertificate) {
      return ApiException('服务器证书校验失败。', cause: error);
    }
    return ApiException('网络请求失败，请稍后重试。', cause: error);
  }

  /// 可直接展示给用户的错误文案。
  final String message;

  /// HTTP 状态码，网络层错误时为 `null`。
  final int? statusCode;

  /// 原始异常，便于日志与排查。
  final Object? cause;

  static String? _serverMessage(Object? body) {
    if (body is Map) {
      final message = body['message'] ?? body['msg'];
      if (message is String && message.isNotEmpty) return message;
    }
    return null;
  }

  @override
  String toString() {
    final code = statusCode == null ? '' : ' ($statusCode)';
    return 'ApiException$code: $message';
  }
}
