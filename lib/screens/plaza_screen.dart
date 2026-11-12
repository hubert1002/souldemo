import 'package:flutter/material.dart';

import '../models.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/core.dart';

class PlazaScreen extends StatefulWidget {
  const PlazaScreen({super.key});

  @override
  State<PlazaScreen> createState() => _PlazaScreenState();
}

class _PlazaScreenState extends State<PlazaScreen> {
  int _topTab = 0;
  int _topic = 0;

  static const _topTabs = ['推荐', '关注', '附近'];
  static const _topics = [
    '# 深夜emo收容所',
    '# 城市漫游',
    '# 一个人也很好',
    '# 今天听的歌',
  ];

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);

    return Column(
      children: [
        _TopTabs(
          tabs: _topTabs,
          selected: _topTab,
          onSelect: (index) {
            setState(() => _topTab = index);
            if (index == 1) {
              showToast(context, '关注流：你关注的 6 位灵魂有 3 条新动态');
            } else if (index == 2) {
              showToast(context, '附近：上海 · 3.2km 内有 47 个同频灵魂');
            }
          },
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.only(bottom: 110 + bottomInset(context)),
            physics: const BouncingScrollPhysics(),
            children: [
              const SizedBox(height: 12),
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  itemCount: _topics.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final on = i == _topic;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _topic = i);
                        showToast(context, '已切换到 ${_topics[i]}');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(99),
                          color: on
                              ? C.purple.withValues(alpha: .22)
                              : Colors.white.withValues(alpha: .04),
                          border: Border.all(
                            color: on
                                ? const Color(0xFFB48CFF)
                                    .withValues(alpha: .5)
                                : Colors.white.withValues(alpha: .1),
                          ),
                        ),
                        child: Text(
                          _topics[i],
                          style: TextStyle(
                            fontSize: 11.5,
                            color: on ? Colors.white : const Color(0xFFCFC5EA),
                            height: 1.2,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: SectionHead(
                  title: '为你同频',
                  subtitle: '基于你的灵魂画像推荐',
                  action: '换一批',
                  onAction: () => showToast(context, '已换一批同频瞬间'),
                ),
              ),
              for (var i = 0; i < state.posts.length; i++)
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
                  child: FadeSlideIn(
                    child: _PostCard(
                      key: ValueKey(state.posts[i].id),
                      post: state.posts[i],
                      onLike: () {
                        final wasLiked = state.posts[i].liked;
                        state.togglePostLike(state.posts[i]);
                        if (!wasLiked) {
                          showToast(
                            context,
                            '已共鸣 · 你的喜欢会出现在 TA 的瞬间里',
                          );
                        }
                      },
                      onFollow: () {
                        state.togglePostFollow(state.posts[i]);
                        showToast(
                          context,
                          state.posts[i].following
                              ? '关注成功，TA 的新瞬间会优先给你'
                              : '已取消关注',
                        );
                      },
                      onComment: () => showToast(
                        context,
                        '打开 ${state.posts[i].comments} 条评论',
                      ),
                      onShare: () => showToast(context, '已复制分享链接'),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TopTabs extends StatelessWidget {
  const _TopTabs({
    required this.tabs,
    required this.selected,
    required this.onSelect,
  });

  final List<String> tabs;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            C.bg,
            C.bg.withValues(alpha: .72),
          ],
          stops: const [.6, 1],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (var i = 0; i < tabs.length; i++)
            GestureDetector(
              onTap: () => onSelect(i),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        tabs[i],
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                              i == selected ? FontWeight.w700 : FontWeight.w500,
                          color: i == selected ? Colors.white : C.muted,
                        ),
                      ),
                    ),
                    Container(
                      width: 18,
                      height: 3,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        gradient: i == selected ? C.gradHorizontal : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const Spacer(),
          GestureDetector(
            onTap: () => showToast(context, '搜索将基于瞬间内容与灵魂标签'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: C.line),
                color: Colors.white.withValues(alpha: .05),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.search, size: 13, color: C.muted),
                  SizedBox(width: 5),
                  Text(
                    '搜瞬间',
                    style: TextStyle(fontSize: 11.5, color: C.muted),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onFollow,
    required this.onComment,
    required this.onShare,
  });

  final Post post;
  final VoidCallback onLike;
  final VoidCallback onFollow;
  final VoidCallback onComment;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: C.line),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: .045),
            Colors.white.withValues(alpha: .015),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SoulAvatar(emoji: post.emoji, ava: post.ava, size: 42),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: C.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      post.meta,
                      style: const TextStyle(fontSize: 10.5, color: C.muted),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onFollow,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(
                      color: post.following
                          ? C.line
                          : const Color(0xFFB48CFF)
                              .withValues(alpha: .45),
                    ),
                    color: post.following
                        ? Colors.transparent
                        : C.purple.withValues(alpha: .12),
                  ),
                  child: Text(
                    post.following ? '已关注' : '关注',
                    style: TextStyle(
                      fontSize: 11,
                      color: post.following
                          ? const Color(0xFF9A90B8)
                          : const Color(0xFFC9B6FF),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          Text.rich(
            TextSpan(
              style: const TextStyle(
                fontSize: 13,
                height: 1.72,
                color: Color(0xFFE7E1F8),
              ),
              children: [
                TextSpan(text: post.text),
                if (post.highlight != null)
                  TextSpan(
                    text: post.highlight,
                    style: const TextStyle(color: Color(0xFFC0A8FF)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              height: 150,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: C.postGradient(post.mediaIndex),
                    ),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0x8C06030E)],
                        stops: [.45, 1],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 10,
                    bottom: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0x6B080412),
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: .16),
                        ),
                      ),
                      child: Text(
                        post.mediaLabel,
                        style: TextStyle(
                          fontSize: 10.5,
                          color: Colors.white.withValues(alpha: .9),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              for (final tag in post.tags)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: C.purple.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: Color(0xFFB7A9DE),
                    ),
                  ),
                ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.only(top: 10),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0x0FFFFFFF)),
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: onLike,
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      TweenAnimationBuilder<double>(
                        key: ValueKey('${post.id}-${post.liked}'),
                        tween: Tween(begin: .6, end: 1),
                        duration: const Duration(milliseconds: 340),
                        curve: Curves.elasticOut,
                        builder: (context, scale, child) =>
                            Transform.scale(scale: scale, child: child),
                        child: Icon(
                          post.liked ? Icons.favorite : Icons.favorite_border,
                          size: 15,
                          color: post.liked
                              ? const Color(0xFFFF6FA0)
                              : const Color(0xFF9E94BC),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${post.likes}',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: post.liked
                              ? const Color(0xFFFF6FA0)
                              : const Color(0xFF9E94BC),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 18),
                _FooterAction(
                  icon: Icons.chat_bubble_outline,
                  label: '${post.comments}',
                  onTap: onComment,
                ),
                const Spacer(),
                _FooterAction(
                  icon: Icons.auto_awesome,
                  label: '分享',
                  onTap: onShare,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterAction extends StatelessWidget {
  const _FooterAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF9E94BC)),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              color: Color(0xFF9E94BC),
            ),
          ),
        ],
      ),
    );
  }
}
