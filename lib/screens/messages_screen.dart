import 'package:flutter/material.dart';

import '../data.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/core.dart';
import 'chat_screen.dart';
import 'friends_screen.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  static const _soulCards = [
    (id: 'yuejian', name: '月见', emoji: '🌙', ava: 'a1', heart: 128, score: 92),
    (id: 'ali', name: '阿鲤', emoji: '🐟', ava: 'a2', heart: 96, score: 88),
    (id: 'xiaoman', name: '小满', emoji: '🌻', ava: 'a3', heart: 320, score: 74),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(18, 8, 18, 110 + bottomInset(context)),
      physics: const BouncingScrollPhysics(),
      children: [
        Row(
          children: [
            const Text(
              '消息',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: C.text,
              ),
            ),
            const Spacer(),
            GlassIconButton(
              onTap: () => showToast(context, '已开启「只接收同频消息」'),
              child: const Text(
                '✧',
                style: TextStyle(fontSize: 16, color: Color(0xFFE8E2FF)),
              ),
            ),
            const SizedBox(width: 8),
            GlassIconButton(
              onTap: () => showToast(context, '消息设置'),
              child: const Text(
                '⋯',
                style: TextStyle(
                  fontSize: 14,
                  letterSpacing: 1,
                  color: Color(0xFFE8E2FF),
                ),
              ),
            ),
          ],
        ),
        SectionHead(
          title: '灵魂伴侣',
          subtitle: '再聊 72 句点亮',
          action: '全部',
          onAction: () => Navigator.of(context).push(
            slideRoute(const FriendsScreen(filter: 'all')),
          ),
        ),
        SizedBox(
          height: 152,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: _soulCards.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final c = _soulCards[i];
              return GestureDetector(
                onTap: () => Navigator.of(context).push(
                  slideRoute(ChatScreen(chatId: c.id)),
                ),
                child: Container(
                  width: 108,
                  padding: const EdgeInsets.fromLTRB(8, 13, 8, 11),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: C.line),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: .05),
                        Colors.white.withValues(alpha: .012),
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SoulRingAvatar(
                        emoji: c.emoji,
                        ava: c.ava,
                        score: c.score,
                      ),
                      const SizedBox(height: 7),
                      Text(
                        c.name,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '心动值 ${c.heart}',
                        style: const TextStyle(fontSize: 9.5, color: C.muted),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '契合度 ${c.score}%',
                        style: const TextStyle(
                          fontSize: 9.5,
                          color: Color(0xFFFFB3CE),
                          letterSpacing: .2,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SectionHead(title: '最近对话'),
        for (final row in recentChats)
          _ChatRow(
            row: row,
            onTap: () => Navigator.of(context).push(
              slideRoute(ChatScreen(chatId: row.chatId)),
            ),
          ),
      ],
    );
  }
}

class _ChatRow extends StatelessWidget {
  const _ChatRow({required this.row, required this.onTap});

  final RecentChat row;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 11),
        child: Row(
          children: [
            SoulAvatar(
              emoji: row.emoji,
              ava: row.ava,
              size: 48,
              online: row.online,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        row.name,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      if (row.chip != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: const Color(0xFFB48CFF)
                                  .withValues(alpha: .35),
                            ),
                          ),
                          child: Text(
                            row.chip!,
                            style: const TextStyle(
                              fontSize: 9,
                              color: Color(0xFFC9B6FF),
                            ),
                          ),
                        ),
                      ],
                      const Spacer(),
                      Text(
                        row.time,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF7E7499),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          row.preview,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: C.muted,
                          ),
                        ),
                      ),
                      if (row.dot)
                        Container(
                          width: 9,
                          height: 9,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: C.gradHorizontal,
                          ),
                        ),
                      if (row.badge > 0)
                        Container(
                          constraints: const BoxConstraints(minWidth: 17),
                          height: 17,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            gradient: C.gradHorizontal,
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            '${row.badge}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              height: 1,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
