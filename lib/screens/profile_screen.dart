import 'package:flutter/material.dart';

import '../data.dart';
import '../models.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/background.dart';
import '../widgets/core.dart';
import 'chat_screen.dart';
import 'moment_screen.dart';
import 'result_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.friendId});

  final String friendId;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final friend = state.friendById(friendId);
    if (friend == null) {
      return Scaffold(
        backgroundColor: C.bg,
        body: const Center(
          child: Text('找不到这位同频者', style: TextStyle(color: C.muted)),
        ),
      );
    }

    final common = commonTags[friend.id] ?? friend.tags;

    return Scaffold(
      backgroundColor: C.bg,
      body: AppBackdrop(
        pinkGlow: false,
        child: Column(
          children: [
            const StatusArea(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.only(bottom: 36 + bottomInset(context)),
                physics: const BouncingScrollPhysics(),
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      SizedBox(
                        height: 158,
                        child: _Cover(
                          onBack: () => Navigator.of(context).maybePop(),
                          onMore: () => _showMore(context, state, friend),
                        ),
                      ),
                      Positioned(
                        left: 16,
                        right: 16,
                        top: 124,
                        child: _Head(friend: friend),
                      ),
                    ],
                  ),
                  const SizedBox(height: 58),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (final tag in friend.tags) _TagPill(tag),
                          ],
                        ),
                        const SizedBox(height: 13),
                        Container(
                          padding: const EdgeInsets.only(left: 11),
                          decoration: const BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                color: Color(0x73B48CFF),
                                width: 2,
                              ),
                            ),
                          ),
                          child: Text(
                            '“${friend.sig}”',
                            style: const TextStyle(
                              fontSize: 12.5,
                              height: 1.72,
                              color: Color(0xFFC9BFE6),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Expanded(
                              child: GradientButton(
                                label: '发消息',
                                height: 44,
                                radius: 14,
                                fontSize: 13,
                                onTap: () {
                                  state.ensureChat(friend);
                                  Navigator.of(context).push(
                                    slideRoute(
                                      ChatScreen(chatId: friend.id),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            _PactButton(
                              icon: Icons.call_outlined,
                              onTap: () =>
                                  showToast(context, '正在发起灵魂语音通话…'),
                            ),
                            const SizedBox(width: 8),
                            _PactButton(
                              icon: Icons.card_giftcard,
                              onTap: () =>
                                  showToast(context, '礼物面板：送 TA 一颗星星 ✦'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        _RelationCard(friend: friend, commonCount: common.length),
                        SectionHead(
                          title: '灵魂画像',
                          action: '完整报告 ›',
                          onAction: () => showToast(context, '查看 TA 的完整灵魂报告'),
                        ),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: C.line),
                            color: Colors.white.withValues(alpha: .03),
                          ),
                          child: Column(
                            children: [
                              TraitBar(label: '共情力', value: friend.trait[0]),
                              TraitBar(label: '好奇心', value: friend.trait[1]),
                              TraitBar(label: '夜行性', value: friend.trait[2]),
                              TraitBar(label: '社交电量', value: friend.trait[3]),
                            ],
                          ),
                        ),
                        SectionHead(
                          title: 'TA 的瞬间',
                          action: '全部 ›',
                          onAction: () => _openMoment(context, friend),
                        ),
                        GridView.count(
                          crossAxisCount: 3,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 7,
                          mainAxisSpacing: 7,
                          children: [
                            for (var i = 0; i < friend.mom.length; i++)
                              _MomentCell(
                                emoji: friend.mom[i],
                                index: i,
                                onTap: () => _openMoment(context, friend),
                              ),
                          ],
                        ),
                        SectionHead(
                          title: '共同点',
                          trailing: const Text(
                            '你们都收藏了这些',
                            style: TextStyle(fontSize: 10, color: Color(0xFF7E7499)),
                          ),
                        ),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (final tag in common) _TagPill(tag),
                          ],
                        ),
                      ],
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

  void _openMoment(BuildContext context, Friend friend) {
    Navigator.of(context).push(
      slideRoute(MomentScreen(friendId: friend.id)),
    );
  }

  void _showMore(BuildContext context, AppState state, Friend friend) {
    showAppSheet(
      context,
      title: '对「${friend.name}」',
      actions: [
        SheetAction(
          label: '分享 TA 的主页',
          onTap: () => showToast(context, '主页链接已复制'),
        ),
        SheetAction(
          label: '举报',
          onTap: () => _showReportReasons(context, friend),
        ),
        SheetAction(
          label: '拉黑',
          danger: true,
          onTap: () => Navigator.of(context).push(
            slideRoute(
              ResultScreen(kind: 'block', friendName: friend.name),
            ),
          ),
        ),
        SheetAction(
          label: '删除好友',
          danger: true,
          onTap: () {
            showToast(context, '已删除好友（演示）');
            final navigator = Navigator.of(context);
            Future<void>.delayed(
              const Duration(milliseconds: 350),
              () => navigator.popUntil((route) => route.isFirst),
            );
          },
        ),
      ],
    );
  }

  void _showReportReasons(BuildContext context, Friend friend) {
    showAppSheet(
      context,
      title: '举报「${friend.name}」· 选择原因',
      actions: [
        for (final reason in const [
          '骚扰或不当内容',
          '虚假身份 / 诈骗',
          '色情或暴力内容',
          '我不感兴趣',
        ])
          SheetAction(
            label: reason,
            onTap: () => Navigator.of(context).push(
              slideRoute(
                ResultScreen(
                  kind: 'report',
                  friendName: friend.name,
                  reason: reason,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Cover extends StatelessWidget {
  const _Cover({required this.onBack, required this.onMore});

  final VoidCallback onBack;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF231A3C), Color(0xFF140E24), Color(0xFF0A0612)],
              stops: [0, .62, 1],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(.68, -1.1),
              radius: 1.3,
              colors: [C.pink.withValues(alpha: .42), Colors.transparent],
              stops: const [0, .58],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(-.84, -.9),
              radius: 1.3,
              colors: [C.purple.withValues(alpha: .58), Colors.transparent],
              stops: const [0, .62],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, 1.16),
              radius: .75,
              colors: [Colors.white.withValues(alpha: .09), Colors.transparent],
              stops: const [0, .72],
            ),
          ),
        ),
        Positioned(
          top: 10,
          left: 16,
          child: BackButtonCircle(onTap: onBack),
        ),
        Positioned(
          top: 8,
          right: 16,
          child: GlassIconButton(
            size: 34,
            onTap: onMore,
            child: const Text(
              '⋯',
              style: TextStyle(fontSize: 13, letterSpacing: 1, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _Head extends StatelessWidget {
  const _Head({required this.friend});

  final Friend friend;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: C.bg,
          ),
          child: SoulAvatar(
            emoji: friend.emoji,
            ava: friend.ava,
            size: 82,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 6),
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
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                          color: C.text,
                        ),
                      ),
                    ),
                    if (friend.online) ...[
                      const SizedBox(width: 7),
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: C.green,
                          boxShadow: [
                            BoxShadow(
                              color: C.green.withValues(alpha: .8),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${friend.age} · ${friend.city} · ${friend.mbti}',
                  style: const TextStyle(fontSize: 10.5, color: C.muted),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScoreRing(
              score: friend.score.toDouble(),
              size: 54,
              stroke: 3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${friend.score}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                  const Text(
                    '%',
                    style: TextStyle(
                      fontSize: 8,
                      color: Color(0xFFFFB3CE),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 3),
            const Text(
              '灵魂契合度',
              style: TextStyle(
                fontSize: 8.5,
                letterSpacing: .5,
                color: Color(0xFF8B80A8),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TagPill extends StatelessWidget {
  const _TagPill(this.tag);

  final String tag;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: C.purple.withValues(alpha: .16),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: const Color(0xFFB48CFF).withValues(alpha: .28),
        ),
      ),
      child: Text(
        tag,
        style: const TextStyle(fontSize: 10, color: C.lavenderSoft),
      ),
    );
  }
}

class _PactButton extends StatelessWidget {
  const _PactButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: .05),
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 46,
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: C.line),
          ),
          child: Icon(icon, size: 19, color: const Color(0xFFDCD4F4)),
        ),
      ),
    );
  }
}

class _RelationCard extends StatelessWidget {
  const _RelationCard({required this.friend, required this.commonCount});

  final Friend friend;
  final int commonCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: C.line),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            C.purple.withValues(alpha: .16),
            Colors.white.withValues(alpha: .02),
          ],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                '你们的关系',
                style: TextStyle(fontSize: 11, color: Color(0xFFB7ADD4)),
              ),
              const Spacer(),
              Text(
                friend.rel,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFFA6C2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text(
                '心动值 ',
                style: TextStyle(fontSize: 10, color: Color(0xFFA99FC4)),
              ),
              Text(
                '${friend.heart}',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFFF9CC0),
                ),
              ),
              const Spacer(),
              Text(
                '距离下一阶段还需 ',
                style: const TextStyle(fontSize: 10, color: Color(0xFFA99FC4)),
              ),
              Text(
                '${friend.target - friend.heart}',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFFF9CC0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          HeartProgress(heart: friend.heart, target: friend.target),
          Container(
            margin: const EdgeInsets.only(top: 11),
            padding: const EdgeInsets.only(top: 10),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0x14FFFFFF))),
            ),
            child: Row(
              children: [
                _RelationStat(value: '${friend.days}', label: '认识天数'),
                _RelationStat(value: '3', label: '连续聊天', divider: true),
                _RelationStat(
                  value: '$commonCount',
                  label: '共同标签',
                  divider: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RelationStat extends StatelessWidget {
  const _RelationStat({
    required this.value,
    required this.label,
    this.divider = false,
  });

  final String value;
  final String label;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: divider
              ? const Border(left: BorderSide(color: Color(0x12FFFFFF)))
              : null,
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: C.text,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 9.5, color: C.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _MomentCell extends StatelessWidget {
  const _MomentCell({
    required this.emoji,
    required this.index,
    required this.onTap,
  });

  final String emoji;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: C.mediaGradient(index),
                border: Border.all(color: Colors.white.withValues(alpha: .07)),
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0x5906030E)],
                  stops: [.55, 1],
                ),
              ),
            ),
            Center(
              child: Text(emoji, style: const TextStyle(fontSize: 24)),
            ),
          ],
        ),
      ),
    );
  }
}
