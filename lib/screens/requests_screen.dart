import 'package:flutter/material.dart';

import '../models.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/background.dart';
import '../widgets/core.dart';
import 'chat_screen.dart';

class RequestsScreen extends StatelessWidget {
  const RequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final pending = state.pendingRequestCount;

    return Scaffold(
      backgroundColor: C.bg,
      body: AppBackdrop(
        pinkGlow: false,
        child: Column(
          children: [
            const StatusArea(),
            PageHeader(
              title: '好友申请',
              subtitle: pending > 0 ? '$pending 位待处理' : '暂无待处理',
            ),
            Expanded(
              child: ListView(
                padding:
                    EdgeInsets.fromLTRB(16, 14, 16, 30 + bottomInset(context)),
                physics: const BouncingScrollPhysics(),
                children: [
                  if (state.requests.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Text(
                        '还没有收到好友申请',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, color: Color(0xFF7E7499)),
                      ),
                    )
                  else
                    for (final request in state.requests)
                      _RequestCard(
                        request: request,
                        onAccept: () {
                          state.acceptRequest(request);
                          showToast(
                            context,
                            '已同意「${request.name}」的好友申请',
                          );
                        },
                        onIgnore: () {
                          state.ignoreRequest(request);
                          showToast(context, '已忽略该申请');
                        },
                        onGreet: () {
                          state.prepareGreeting(request);
                          final navigator = Navigator.of(context);
                          navigator.popUntil((route) => route.isFirst);
                          navigator.push(
                            slideRoute(
                              ChatScreen(
                                chatId: request.id,
                                initialDraft:
                                    '嗨，${request.name}，看到你的申请啦 ✦',
                              ),
                            ),
                          );
                        },
                      ),
                  const Padding(
                    padding: EdgeInsets.only(top: 18, bottom: 4),
                    child: Text(
                      '同意后对方会出现在好友列表 · 也可以先打个招呼',
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
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.request,
    required this.onAccept,
    required this.onIgnore,
    required this.onGreet,
  });

  final FriendRequest request;
  final VoidCallback onAccept;
  final VoidCallback onIgnore;
  final VoidCallback onGreet;

  @override
  Widget build(BuildContext context) {
    return FadeSlideIn(
      child: Container(
        margin: const EdgeInsets.only(bottom: 11),
        padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: C.line),
          color: Colors.white.withValues(alpha: .03),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SoulAvatar(
                  emoji: request.emoji,
                  ava: request.ava,
                  size: 42,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: C.text,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${request.age} · ${request.city} · ${request.mbti} · ${request.time}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF9A90B8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${request.score}%',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFFFB3CE),
                  ),
                ),
              ],
            ),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 11),
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .04),
                borderRadius: BorderRadius.circular(10),
                border: const Border(
                  left: BorderSide(color: Color(0x73B48CFF), width: 2),
                ),
              ),
              child: Text(
                '「${request.note}」',
                style: const TextStyle(
                  fontSize: 11.5,
                  height: 1.65,
                  color: Color(0xFFC9BFE6),
                ),
              ),
            ),
            const SizedBox(height: 11),
            if (request.status == 'pending')
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: onIgnore,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: C.line),
                          color: Colors.white.withValues(alpha: .04),
                        ),
                        child: const Text(
                          '忽略',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFFA99FC4),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: onAccept,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: C.gradHorizontal,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFB45CFF)
                                  .withValues(alpha: .35),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Text(
                          '同意',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            else if (request.status == 'accepted')
              Row(
                children: [
                  const _StatusPill(text: '✓ 已同意'),
                  const Spacer(),
                  GestureDetector(
                    onTap: onGreet,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFB48CFF)
                              .withValues(alpha: .4),
                        ),
                        color: C.purple.withValues(alpha: .14),
                      ),
                      child: const Text(
                        '打个招呼',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFFD9C9FF),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            else
              const _StatusPill(text: '已忽略', gray: true),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.text, this.gray = false});

  final String text;
  final bool gray;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        color: gray
            ? Colors.white.withValues(alpha: .04)
            : C.cyan.withValues(alpha: .1),
        border: Border.all(
          color: gray ? C.line : C.cyan.withValues(alpha: .25),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: gray ? const Color(0xFF9A90B8) : const Color(0xFF8FE7D6),
        ),
      ),
    );
  }
}
