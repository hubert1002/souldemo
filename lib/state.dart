import 'package:flutter/widgets.dart';

import 'data.dart';
import 'models.dart';

/// 全局可变状态：模拟原型中的 JS 内存数据。
class AppState extends ChangeNotifier {
  AppState() {
    me = seedMe();
    friends = seedFriends();
    requests = seedRequests();
    chats = seedChats();
    posts = seedPosts();
  }

  int tabIndex = 0;
  bool messagesDot = true;

  late final MeProfile me;
  late final List<Friend> friends;
  late final List<FriendRequest> requests;
  late final Map<String, ChatThread> chats;
  late final List<Post> posts;

  void setTab(int index) {
    if (tabIndex == index) return;
    tabIndex = index;
    if (index == 2) messagesDot = false;
    notifyListeners();
  }

  void openMessagesTab() {
    tabIndex = 2;
    messagesDot = false;
    notifyListeners();
  }

  Friend? friendById(String id) {
    for (final f in friends) {
      if (f.id == id) return f;
    }
    return null;
  }

  ChatThread? chatById(String id) => chats[id];

  ChatThread ensureChat(Friend f) {
    final existing = chats[f.id];
    if (existing != null) return existing;
    final chat = ChatThread(
      id: f.id,
      name: f.name,
      emoji: f.emoji,
      ava: f.ava,
      meta: '灵魂契合度 ${f.score}% · ${f.online ? '在线' : '最近活跃'}',
      heart: f.heart,
      target: f.target,
      isGroup: f.isGroup,
      messages: [
        ChatMessage.system('你们已成为好友 · 灵魂契合度 ${f.score}%'),
        ChatMessage.incoming('嗨，终于在这里遇见你了 ✦'),
      ],
    );
    chats[f.id] = chat;
    notifyListeners();
    return chat;
  }

  void addMessage(String chatId, ChatMessage message) {
    chats[chatId]?.messages.add(message);
    notifyListeners();
  }

  /// 返回 true 表示本次加值后刚好点亮。
  bool bumpHeart(String chatId, int amount) {
    final chat = chats[chatId];
    if (chat == null) return false;
    final before = chat.heart;
    chat.heart += amount;
    notifyListeners();
    return before < chat.target && chat.heart >= chat.target;
  }

  void togglePostLike(Post post) {
    post.liked = !post.liked;
    post.likes += post.liked ? 1 : -1;
    notifyListeners();
  }

  void togglePostFollow(Post post) {
    post.following = !post.following;
    notifyListeners();
  }

  Friend _friendFromRequest(FriendRequest r) => Friend(
        id: r.id,
        name: r.name,
        emoji: r.emoji,
        ava: r.ava,
        age: r.age,
        city: r.city,
        mbti: r.mbti,
        score: r.score,
        heart: 12,
        target: 200,
        days: 1,
        rel: '好友',
        group: 'all',
        online: true,
        sig: r.note,
        tags: [r.mbti, '同频新朋友'],
        trait: const [72, 80, 66, 58],
        mom: const ['✦', '🌙', '🫧', '🌿', '☕', '🎧'],
      );

  Friend _ensureFriendFromRequest(FriendRequest r) {
    final existing = friendById(r.id);
    if (existing != null) return existing;
    final friend = _friendFromRequest(r);
    // 群聊永远在列表末尾
    friends.insert(friends.length - 1, friend);
    notifyListeners();
    return friend;
  }

  void acceptRequest(FriendRequest r) {
    if (r.status != 'pending') return;
    r.status = 'accepted';
    _ensureFriendFromRequest(r);
    notifyListeners();
  }

  void ignoreRequest(FriendRequest r) {
    if (r.status != 'pending') return;
    r.status = 'ignored';
    notifyListeners();
  }

  Friend prepareGreeting(FriendRequest r) {
    final friend = _ensureFriendFromRequest(r);
    ensureChat(friend);
    return friend;
  }

  int get pendingRequestCount =>
      requests.where((r) => r.status == 'pending').length;

  int get onlineFriendCount => friends.where((f) => f.online).length;

  int get soulCount => friends.where((f) => f.group == 'soul').length;

  int get closeCount => friends.where((f) => f.group == 'close').length;

  int get groupCount => friends.where((f) => f.group == 'group').length;

  Moment? buildMoment(String id) {
    if (id == 'me') {
      return Moment(
        isMe: true,
        name: me.name,
        emoji: me.emoji,
        ava: me.ava,
        meta: '今天 02:41 · 上海',
        text: meMomentText,
        grid: List<String>.from(meMomentGrid),
        likes: 128,
        comments: [
          for (final c in meMomentComments)
            MomentComment(name: c[0], emoji: c[1], ava: c[2], text: c[3]),
        ],
      );
    }

    final f = friendById(id);
    if (f == null) return null;

    final grid = List<String>.from(f.mom);
    const extra = ['✦', '🌙', '🫧'];
    while (grid.length < 9) {
      grid.add(extra[grid.length % extra.length]);
    }
    final rawComments = momentComments[id];
    final comments = rawComments != null
        ? [
            for (final c in rawComments)
              MomentComment(name: c[0], emoji: c[1], ava: c[2], text: c[3]),
          ]
        : [
            MomentComment(
              name: '月见',
              emoji: '🌙',
              ava: 'a1',
              text: '这条的光线很好看，像一段没有说完的话。',
            ),
            MomentComment(
              name: '木木',
              emoji: '🌿',
              ava: 'a4',
              text: '看完忽然安静下来了。',
            ),
          ];

    return Moment(
      isMe: false,
      name: f.name,
      emoji: f.emoji,
      ava: f.ava,
      meta: '今天 02:41 · ${f.city}',
      text: momentText[id] ??
          '${f.sig}\n\n今天也把这一小块时间，留给愿意停下来的人。',
      grid: grid,
      likes: f.heart + 40,
      comments: comments,
    );
  }

  void saveProfile({
    required String name,
    required String sig,
    required String emoji,
    required String ava,
    required List<String> tags,
  }) {
    me.name = name;
    me.sig = sig;
    me.emoji = emoji;
    me.ava = ava;
    me.tags = List<String>.from(tags);
    notifyListeners();
  }
}

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({
    super.key,
    required AppState state,
    required super.child,
  }) : super(notifier: state);

  static AppState of(BuildContext context, {bool listen = true}) {
    final scope = listen
        ? context.dependOnInheritedWidgetOfExactType<AppScope>()
        : context.getInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found');
    return scope!.notifier!;
  }
}
