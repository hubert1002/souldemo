import 'api_client.dart';
import 'api_config.dart';
import 'feed_repository.dart';

/// 应用级服务入口。
///
/// 页面与 `AppState` 只从这里取 repository，不直接创建 [ApiClient]：
/// ```dart
/// final posts = await Services.feed.fetchFeed();
/// ```
///
/// 默认走 mock；接入真实后端时用 `--dart-define=USE_MOCK=false` 切换，
/// 并用 `--dart-define=API_BASE_URL=...` 指定地址。
abstract final class Services {
  /// 全局共享的 HTTP 客户端，登录后调用 `Services.apiClient.setToken()`。
  static final ApiClient apiClient = ApiClient();

  /// 广场动态数据源。
  static final FeedRepository feed = ApiConfig.useMock
      ? const MockFeedRepository()
      : RemoteFeedRepository(apiClient);
}
