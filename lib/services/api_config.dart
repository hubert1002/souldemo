/// 后端与网络配置。
///
/// 通过 `--dart-define` 注入，例如接入真实后端时：
/// ```bash
/// flutter run -d macos \
///   --dart-define=USE_MOCK=false \
///   --dart-define=API_BASE_URL=https://api.xingyu.example.com
/// ```
class ApiConfig {
  const ApiConfig._();

  /// 是否继续使用 `lib/data.dart` 中的本地 mock 数据。
  ///
  /// 默认为 `true`，保证没有后端时原型也能完整运行。
  static const bool useMock = bool.fromEnvironment(
    'USE_MOCK',
    defaultValue: true,
  );

  /// 后端根地址，仅在 [useMock] 为 `false` 时生效。
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.xingyu.example.com',
  );
}
