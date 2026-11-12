import 'package:flutter/material.dart';

import '../models.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/background.dart';
import '../widgets/core.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';
import 'requests_screen.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key, this.filter = 'all'});

  final String filter;

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  late String _filter = widget.filter;
  String _query = '';

  static const _groups = [
    ('soul', '灵魂伴侣'),
    ('close', '密友'),
    ('all', '其他好友'),
    ('group', '群聊'),
  ];

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);

    return Scaffold(
      backgroundColor: C.bg,
      body: AppBackdrop(
        pinkGlow: false,
        child: Column(
          children: [
            const StatusArea(),
            PageHeader(
              title: '好友',
              subtitle:
                  '${state.friends.length - state.groupCount} 位好友 · ${state.onlineFriendCount} 位在线',
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(16, 14, 16, 30 + bottomInset(context)),
                physics: const BouncingScrollPhysics(),
                children: [
                  _SearchField(
                    onChanged: (v) => setState(() => _query = v),
                  ),
                  const SizedBox(height: 12),
                  _RequestBanner(
                    pending: state.pendingRequestCount,
                    onTap: () => Navigator.of(context).push(
                      slideRoute(const RequestsScreen()),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _FilterTabs(
                    selected: _filter,
                    counts: [
                      state.friends.length,
                      state.soulCount,
                      state.closeCount,
                      state.groupCount,
                    ],
                    onSelect: (f) => setState(() => _filter = f),
                  ),
                  const SizedBox(height: 4),
                  ..._buildList(context, state),
                  const Padding(
                    padding: EdgeInsets.only(top: 18, bottom: 4),
                    child: Text(
                      '好友上限 200 人 · 灵魂匹配可遇见更多同频者',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        height: 1.7,
                        color: Color(0xFF5E5478),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildList(BuildContext context, AppState state) {
    final q = _query.trim().toLowerCase();
    var shown = 0;
    final children = <Widget>[];

    for (final g in _groups) {
      final key = g.$1;
      final label = g.$2;
      if (_filter != 'all' && _filter != key) continue;

      final arr = state.friends.where((f) {
        if (f.group != key) return false;
        if (q.isEmpty) return true;
        return f.name.toLowerCase().contains(q) ||
            f.id.toLowerCase().contains(q);
      }).toList();

      if (arr.isEmpty) continue;

      if (_filter == 'all') {
        children.add(
          Padding(
            padding: const EdgeInsets.only(top: 14, bottom: 3, left: 4),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 9.5,
                letterSpacing: 1.4,
                color: Color(0xFF7E7499),
              ),
            ),
          ),
        );
      }

      for (final f in arr) {
        children.add(_FriendRow(
          friend: f,
          onTap: () => _openFriend(context, state, f),
        ));
        shown++;
      }
    }

    if (shown == 0) {
      children.add(
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Text(
            '没有找到同频的人，换个关键词试试',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: Color(0xFF7E7499)),
          ),
        ),
      );
    }

    return children;
  }

  void _openFriend(BuildContext context, AppState state, Friend f) {
    if (f.isGroup) {
      final navigator = Navigator.of(context);
      navigator.popUntil((route) => route.isFirst);
      navigator.push(slideRoute(const ChatScreen(chatId: 'party')));
      return;
    }
    Navigator.of(context).push(
      slideRoute(ProfileScreen(friendId: f.id)),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: C.line),
        color: Colors.white.withValues(alpha: .05),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 14, color: Color(0xFF8C82A8)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              style: const TextStyle(fontSize: 12, color: Colors.white),
              cursorColor: C.lavender,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                hintText: '搜索昵称 / 灵魂编号',
                hintStyle: TextStyle(fontSize: 12, color: Color(0xFF7E7499)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestBanner extends StatelessWidget {
  const _RequestBanner({required this.pending, required this.onTap});

  final int pending;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final title = pending > 0 ? '$pending 位同频者想认识你' : '暂无新的好友申请';
    final sub = pending > 0 ? '通过后即可开始聊天' : '去广场看看今天的同频瞬间';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFB48CFF).withValues(alpha: .35),
          ),
          gradient: LinearGradient(
            colors: [
              C.purple.withValues(alpha: .22),
              C.pink.withValues(alpha: .12),
            ],
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Text('✦', style: TextStyle(fontSize: 14)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sub,
                    style: const TextStyle(
                      fontSize: 9.5,
                      color: Color(0xFFCFC2EC),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(99),
                gradient: const LinearGradient(
                  colors: [Color(0xFFE5D4FF), Color(0xFFFFB7CC)],
                ),
              ),
              child: const Text(
                '查看',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: C.dark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterTabs extends StatelessWidget {
  const _FilterTabs({
    required this.selected,
    required this.counts,
    required this.onSelect,
  });

  final String selected;
  final List<int> counts;
  final ValueChanged<String> onSelect;

  static const _items = [
    ('all', '全部'),
    ('soul', '灵魂伴侣'),
    ('close', '密友'),
    ('group', '群聊'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 7),
        itemBuilder: (context, i) {
          final on = selected == _items[i].$1;
          return GestureDetector(
            onTap: () => onSelect(_items[i].$1),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(99),
                color: on
                    ? C.purple.withValues(alpha: .24)
                    : Colors.white.withValues(alpha: .04),
                border: Border.all(
                  color: on
                      ? const Color(0xFFB48CFF).withValues(alpha: .5)
                      : C.line,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _items[i].$2,
                    style: TextStyle(
                      fontSize: 11,
                      color: on ? Colors.white : const Color(0xFFB7ADD4),
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '${counts[i]}',
                    style: TextStyle(
                      fontSize: 9.5,
                      color: on ? const Color(0xFFC9B6FF) : const Color(0xFF8C82A8),
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FriendRow extends StatelessWidget {
  const _FriendRow({required this.friend, required this.onTap});

  final Friend friend;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final sub = friend.isGroup
        ? (friend.sub ?? '')
        : '${friend.city} · 认识 ${friend.days} 天 · 心动值 ${friend.heart}';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          children: [
            SoulAvatar(
              emoji: friend.emoji,
              ava: friend.ava,
              size: 46,
              online: friend.online,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          friend.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: friend.group == 'soul'
                              ? C.pink.withValues(alpha: .14)
                              : C.purple.withValues(alpha: .18),
                          border: Border.all(
                            color: friend.group == 'soul'
                                ? const Color(0xFFFF78A0)
                                    .withValues(alpha: .42)
                                : const Color(0xFFB48CFF)
                                    .withValues(alpha: .3),
                          ),
                        ),
                        child: Text(
                          friend.isGroup ? '群聊' : friend.rel,
                          style: TextStyle(
                            fontSize: 9,
                            color: friend.group == 'soul'
                                ? const Color(0xFFFFA6C2)
                                : const Color(0xFFC9B6FF),
                            height: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    sub,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10.5, color: C.muted),
                  ),
                ],
              ),
            ),
            if (!friend.isGroup)
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${friend.score}',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFFFB3CE),
                        ),
                      ),
                      const TextSpan(
                        text: '%',
                        style: TextStyle(
                          fontSize: 8.5,
                          color: Color(0xFF9A90B8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
