import '../data.dart';
import '../models.dart';
import 'api_client.dart';
import 'api_exception.dart';

/// 广场动态的数据访问接口。
///
/// 页面和状态层只依赖这个接口，后续接后端时替换实现即可。
abstract interface class FeedRepository {
  Future<List<Post>> fetchFeed({int page = 1, int pageSize = 20});
}

/// 本地 mock 实现：直接读取 `lib/data.dart` 的种子数据。
class MockFeedRepository implements FeedRepository {
  const MockFeedRepository();

  @override
  Future<List<Post>> fetchFeed({int page = 1, int pageSize = 20}) async {
    // 模拟一点网络延迟，方便验证加载态。
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final all = seedPosts();
    final start = (page - 1) * pageSize;
    if (start >= all.length) return <Post>[];
    return all.skip(start).take(pageSize).toList();
  }
}

/// 真实后端实现。
///
/// 约定的响应结构：
/// ```json
/// {
///   "data": [
///     {
///       "id": "p1",
///       "name": "月见",
///       "emoji": "🌙",
///       "ava": "a1",
///       "meta": "2 小时前 · 上海",
///       "text": "凌晨三点的城市……",
///       "highlight": "同一片星空下",
///       "mediaLabel": "夜色",
///       "mediaIndex": 2,
///       "tags": ["# 深夜emo收容所"],
///       "likes": 128,
///       "comments": 12,
///       "following": false,
///       "liked": false
///     }
///   ],
///   "page": 1,
///   "total": 42
/// }
/// ```
class RemoteFeedRepository implements FeedRepository {
  const RemoteFeedRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<Post>> fetchFeed({int page = 1, int pageSize = 20}) async {
    final json = await _client.getJson(
      '/feed',
      query: <String, dynamic>{'page': page, 'pageSize': pageSize},
    );
    final data = json['data'];
    if (data is! List) {
      throw const ApiException('服务器返回的动态列表格式不正确。');
    }
    return <Post>[
      for (final item in data)
        if (item is Map) postFromJson(Map<String, dynamic>.from(item)),
    ];
  }
}

/// 示例：把接口 JSON 转成 [Post]。
///
/// 字段缺失时使用安全默认值，避免后端迭代时直接崩溃。
Post postFromJson(Map<String, dynamic> json) {
  final tags = json['tags'];
  return Post(
    id: json['id']?.toString() ?? '',
    name: json['name'] as String? ?? '',
    emoji: json['emoji'] as String? ?? '✦',
    ava: json['ava'] as String? ?? 'a1',
    meta: json['meta'] as String? ?? '',
    text: json['text'] as String? ?? '',
    highlight: json['highlight'] as String?,
    mediaLabel: json['mediaLabel'] as String? ?? '',
    mediaIndex: (json['mediaIndex'] as num?)?.toInt() ?? 0,
    tags: <String>[
      if (tags is List)
        for (final tag in tags)
          if (tag is String) tag,
    ],
    likes: (json['likes'] as num?)?.toInt() ?? 0,
    comments: (json['comments'] as num?)?.toInt() ?? 0,
    following: json['following'] as bool? ?? false,
    liked: json['liked'] as bool? ?? false,
  );
}
