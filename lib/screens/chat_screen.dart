import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/background.dart';
import '../widgets/core.dart';
import 'profile_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.chatId,
    this.initialDraft,
  });

  final String chatId;
  final String? initialDraft;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scroll = ScrollController();
  final TextEditingController _input = TextEditingController();
  final FocusNode _focus = FocusNode();
  final math.Random _random = math.Random();

  Timer? _typingTimer;
  Timer? _replyTimer;
  Timer? _draftTimer;
  bool _typing = false;
  int _sentCount = 0;

  static const _replyPool = [
    '哈哈，我们好像真的挺同频的',
    '这个话题我可以聊一整晚',
    '你平时都这个点才睡吗？',
    '突然好奇，你会怎么形容今天的自己',
    '刚给你点了关注，别嫌我冒犯 😄',
    '我这边窗外有只猫一直在叫，像在附和',
    '你发的瞬间我都看了，很安静但很有画面感',
    '要不要做个灵魂问答？看看我们合不合拍',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialDraft != null) {
      _draftTimer = Timer(const Duration(milliseconds: 420), () {
        if (!mounted) return;
        _input.text = widget.initialDraft!;
        _input.selection = TextSelection.collapsed(
          offset: _input.text.length,
        );
        _focus.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _replyTimer?.cancel();
    _draftTimer?.cancel();
    _scroll.dispose();
    _input.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool animate = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      final target = _scroll.position.maxScrollExtent;
      if (animate) {
        _scroll.animateTo(
          target,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
        );
      } else {
        _scroll.jumpTo(target);
      }
    });
  }

  String _nowText() {
    final d = DateTime.now();
    return '${d.hour.toString().padLeft(2, '0')}:'
        '${d.minute.toString().padLeft(2, '0')}';
  }

  void _send() {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    final state = AppScope.of(context);
    final chat = state.chatById(widget.chatId);
    if (chat == null) return;

    state.addMessage(
      widget.chatId,
      ChatMessage.outgoing(text, time: _nowText()),
    );
    _input.clear();
    _focus.requestFocus();
    _sentCount++;
    final reached = state.bumpHeart(widget.chatId, 1);
    if (reached) {
      showToast(context, '💜 你们点亮了「灵魂伴侣」');
    }
    _scrollToBottom(animate: true);

    _typingTimer?.cancel();
    _replyTimer?.cancel();

    _typingTimer = Timer(const Duration(milliseconds: 520), () {
      if (!mounted) return;
      setState(() => _typing = true);
      _scrollToBottom(animate: true);
    });

    _replyTimer = Timer(
      Duration(milliseconds: 1750 + _random.nextInt(900)),
      () {
        if (!mounted) return;
        setState(() => _typing = false);
        final reply = _sentCount == 2
            ? '对了，我看到你的灵魂画像里写着「夜行性 95」…我们可能是同一类人'
            : _replyPool[_random.nextInt(_replyPool.length)];
        final latestState = AppScope.of(context);
        latestState.addMessage(
          widget.chatId,
          ChatMessage.incoming(reply),
        );
        latestState.bumpHeart(widget.chatId, 2);
        _scrollToBottom(animate: true);
      },
    );
  }

  void _openProfile(ChatThread chat) {
    final state = AppScope.of(context);
    final friend = state.friendById(widget.chatId);
    if (friend != null && !friend.isGroup) {
      Navigator.of(context).push(
        slideRoute(ProfileScreen(friendId: friend.id)),
      );
    } else {
      showToast(context, '群聊暂不支持查看个人主页');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final chat = state.chatById(widget.chatId);
    if (chat == null) {
      return Scaffold(
        backgroundColor: C.bg,
        body: const Center(
          child: Text('会话不存在', style: TextStyle(color: C.muted)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: C.bg,
      resizeToAvoidBottomInset: true,
      body: AppBackdrop(
        pinkGlow: false,
        child: Column(
          children: [
            const StatusArea(),
            _ChatHeader(
              chat: chat,
              onBack: () => Navigator.of(context).maybePop(),
              onMore: () => showToast(context, '更多：举报 / 拉黑 / 灵魂关系'),
              onOpenProfile: () => _openProfile(chat),
            ),
            _HeartBar(chat: chat),
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                physics: const BouncingScrollPhysics(),
                itemCount: chat.messages.length,
                itemBuilder: (context, index) {
                  final message = chat.messages[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 13),
                    child: _MessageTile(
                      message: message,
                      chat: chat,
                      onVoicePlay: () => showToast(context, '正在播放语音…'),
                      onQuizAnswered: () {
                        final reached =
                            AppScope.of(context).bumpHeart(widget.chatId, 3);
                        showToast(context, '灵魂问答契合 · 心动值 +3');
                        if (reached) {
                          Future<void>.delayed(
                            const Duration(milliseconds: 1900),
                            () {
                              if (context.mounted) {
                                showToast(context, '💜 你们点亮了「灵魂伴侣」');
                              }
                            },
                          );
                        }
                      },
                    ),
                  );
                },
              ),
            ),
            if (_typing) _TypingIndicator(name: chat.name),
            _Icebreakers(
              onPick: (text) {
                _input.text = text;
                _input.selection = TextSelection.collapsed(
                  offset: _input.text.length,
                );
                _focus.requestFocus();
              },
            ),
            _Composer(
              controller: _input,
              focusNode: _focus,
              onSend: _send,
              onVoice: () => showToast(context, '按住说话，松手发送'),
              onEmoji: () => showToast(context, '表情面板即将上线'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader({
    required this.chat,
    required this.onBack,
    required this.onMore,
    required this.onOpenProfile,
  });

  final ChatThread chat;
  final VoidCallback onBack;
  final VoidCallback onMore;
  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0x0FFFFFFF))),
      ),
      child: Row(
        children: [
          BackButtonCircle(onTap: onBack),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: onOpenProfile,
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  SoulAvatar(emoji: chat.emoji, ava: chat.ava, size: 36),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chat.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: C.text,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          chat.meta,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF9C90BB),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          GlassIconButton(
            size: 32,
            onTap: onMore,
            child: const Text(
              '⋯',
              style: TextStyle(fontSize: 13, letterSpacing: 1, color: Color(0xFFE8E2FF)),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeartBar extends StatelessWidget {
  const _HeartBar({required this.chat});

  final ChatThread chat;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 9, 16, 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0x0DFFFFFF))),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text.rich(
                TextSpan(
                  style: const TextStyle(fontSize: 10, color: Color(0xFFA99FC4)),
                  children: [
                    const TextSpan(text: '心动值 '),
                    TextSpan(
                      text: '${chat.heart}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFFF9CC0),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text.rich(
                TextSpan(
                  style: const TextStyle(fontSize: 10, color: Color(0xFFA99FC4)),
                  children: [
                    const TextSpan(text: '点亮灵魂伴侣还需 '),
                    TextSpan(
                      text: '${chat.heartLeft}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFFF9CC0),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          HeartProgress(heart: chat.heart, target: chat.target),
        ],
      ),
    );
  }
}

class _MessageTile extends StatelessWidget {
  const _MessageTile({
    required this.message,
    required this.chat,
    required this.onVoicePlay,
    required this.onQuizAnswered,
  });

  final ChatMessage message;
  final ChatThread chat;
  final VoidCallback onVoicePlay;
  final VoidCallback onQuizAnswered;

  @override
  Widget build(BuildContext context) {
    if (message.kind == MsgKind.system) {
      return Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 300),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .05),
            borderRadius: BorderRadius.circular(99),
            border: Border.all(
              color: Colors.white.withValues(alpha: .06),
            ),
          ),
          child: Text(
            message.text ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              height: 1.5,
              color: Color(0xFF8C82A8),
            ),
          ),
        ),
      );
    }

    final outgoing = message.kind == MsgKind.outgoing;

    Widget bubble;
    if (message.kind == MsgKind.quiz) {
      bubble = _QuizCard(onAnswered: onQuizAnswered);
    } else if (message.voice) {
      bubble = _VoiceBubble(
        duration: message.duration ?? '0:08',
        bars: message.bars,
        onPlay: onVoicePlay,
      );
    } else if (message.image) {
      bubble = ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 170,
          height: 118,
          child: Stack(
            fit: StackFit.expand,
            children: [
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(-.5, -.6),
                    radius: 1.2,
                    colors: [
                      Color(0xFFFFC8A0),
                      Color(0xFFD06A9E),
                      Color(0xFF3A1A5C),
                    ],
                    stops: [0, .48, 1],
                  ),
                ),
              ),
              Positioned(
                left: 8,
                bottom: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0x66080412),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    message.label ?? '图片',
                    style: TextStyle(
                      fontSize: 9.5,
                      color: Colors.white.withValues(alpha: .92),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      bubble = Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: BoxDecoration(
          color: outgoing ? null : Colors.white.withValues(alpha: .08),
          gradient: outgoing ? C.grad : null,
          border: outgoing
              ? null
              : Border.all(color: Colors.white.withValues(alpha: .06)),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(outgoing ? 16 : 5),
            bottomRight: Radius.circular(outgoing ? 5 : 16),
          ),
          boxShadow: outgoing
              ? [
                  BoxShadow(
                    color: const Color(0xFFB45CFF).withValues(alpha: .35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Text(
          message.text ?? '',
          style: const TextStyle(
            fontSize: 12.5,
            height: 1.62,
            color: Color(0xFFF1ECFC),
          ),
        ),
      );
    }

    return Align(
      alignment: outgoing ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * .86,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!outgoing) ...[
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: SoulAvatar(
                  emoji: chat.emoji,
                  ava: chat.ava,
                  size: 32,
                ),
              ),
              const SizedBox(width: 9),
            ],
            Flexible(child: bubble),
          ],
        ),
      ),
    );
  }
}

class _VoiceBubble extends StatefulWidget {
  const _VoiceBubble({
    required this.duration,
    required this.bars,
    required this.onPlay,
  });

  final String duration;
  final List<double> bars;
  final VoidCallback onPlay;

  @override
  State<_VoiceBubble> createState() => _VoiceBubbleState();
}

class _VoiceBubbleState extends State<_VoiceBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _playing = false;
  Timer? _stopTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _stopTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _play() {
    widget.onPlay();
    _stopTimer?.cancel();
    setState(() => _playing = true);
    _controller.repeat(reverse: true);
    _stopTimer = Timer(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      setState(() => _playing = false);
      _controller.stop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bars = widget.bars.isEmpty
        ? const [7.0, 12.0, 8.0, 15.0, 6.0, 11.0, 14.0, 9.0, 6.0, 12.0]
        : widget.bars;

    return GestureDetector(
      onTap: _play,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        decoration: BoxDecoration(
          color: C.purple.withValues(alpha: .2),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(5),
            bottomRight: Radius.circular(16),
          ),
          border: Border.all(
            color: const Color(0xFFB48CFF).withValues(alpha: .3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 18,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      for (var i = 0; i < bars.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(right: 2),
                          child: Transform.scale(
                            scaleY: _playing
                                ? .4 +
                                    1.1 *
                                        (.5 +
                                            .5 *
                                                math.sin(
                                                  2 *
                                                          math.pi *
                                                          _controller.value +
                                                      i * .7,
                                                ))
                                : 1,
                            child: Container(
                              width: 2,
                              height: bars[i],
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                gradient: const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Color(0xFFD9C9FF), Color(0xFF8B5CF6)],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(width: 9),
            Text(
              '▸ ${widget.duration}',
              style: const TextStyle(fontSize: 10, color: Color(0xFFCFC0F0)),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuizCard extends StatefulWidget {
  const _QuizCard({required this.onAnswered});

  final VoidCallback onAnswered;

  @override
  State<_QuizCard> createState() => _QuizCardState();
}

class _QuizCardState extends State<_QuizCard> {
  int? _picked;

  static const _options = [
    'A. 一首能循环一整晚的歌',
    'B. 一首前奏一响就回到某个夏天的歌',
    'C. 一首没有人声、只有雨的纯音乐',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFB48CFF).withValues(alpha: .34),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            C.purple.withValues(alpha: .22),
            C.pink.withValues(alpha: .12),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '灵魂问答 · 第 3 题',
            style: TextStyle(
              fontSize: 9.5,
              letterSpacing: 1.6,
              color: Color(0xFFC9B6FF),
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            '如果只能带一首歌去荒岛，你会带哪首？',
            style: TextStyle(
              fontSize: 12.5,
              height: 1.6,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < _options.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: GestureDetector(
                onTap: () {
                  if (_picked != null) return;
                  setState(() => _picked = i);
                  widget.onAnswered();
                },
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: _picked == i
                        ? null
                        : Colors.white.withValues(alpha: .05),
                    gradient: _picked == i
                        ? LinearGradient(
                            colors: [
                              C.pink.withValues(alpha: .3),
                              C.purple.withValues(alpha: .3),
                            ],
                          )
                        : null,
                    border: Border.all(
                      color: _picked == i
                          ? const Color(0xFFFF8FB1)
                          : Colors.white.withValues(alpha: .12),
                    ),
                  ),
                  child: Text(
                    _options[i],
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.4,
                      color: _picked == i
                          ? Colors.white
                          : const Color(0xFFE4DCF8),
                    ),
                  ),
                ),
              ),
            ),
          if (_picked != null)
            const Padding(
              padding: EdgeInsets.only(top: 3),
              child: Text(
                '✦ 你们的选择一致 · 契合度 +3，心动值 +3',
                style: TextStyle(fontSize: 10.5, color: Color(0xFF8FE7D6)),
              ),
            ),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator({required this.name});

  final String name;

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => Row(
                children: [
                  for (var i = 0; i < 3; i++)
                    Padding(
                      padding: const EdgeInsets.only(right: 3),
                      child: Opacity(
                        opacity: .3 +
                            .7 *
                                (.5 +
                                    .5 *
                                        math.sin(
                                          2 * math.pi * _controller.value -
                                              i * .6,
                                        )),
                        child: Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFA98CFF),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 3),
            Text(
              '${widget.name} 正在输入…',
              style: const TextStyle(fontSize: 10, color: C.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _Icebreakers extends StatelessWidget {
  const _Icebreakers({required this.onPick});

  final ValueChanged<String> onPick;

  static const _items = [
    ('今天有什么小事让你开心？', '今天发生过什么小事让你开心？'),
    ('如果现在能瞬移…', '如果现在能瞬移，你想去哪？'),
    ('分享一首最近循环的歌', '分享一首你最近单曲循环的歌吧'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 7),
        itemBuilder: (context, i) {
          return GestureDetector(
            onTap: () => onPick(_items[i].$2),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(99),
                color: C.purple.withValues(alpha: .1),
                border: Border.all(
                  color: const Color(0xFFB48CFF).withValues(alpha: .28),
                ),
              ),
              child: Text(
                _items[i].$1,
                style: const TextStyle(
                  fontSize: 10.5,
                  color: Color(0xFFC9BCE8),
                  height: 1.2,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.focusNode,
    required this.onSend,
    required this.onVoice,
    required this.onEmoji,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSend;
  final VoidCallback onVoice;
  final VoidCallback onEmoji;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(14, 8, 14, 8 + bottomInset(context)),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0x0FFFFFFF))),
      ),
      child: Row(
        children: [
          _ComposerIcon(icon: Icons.mic_none_rounded, onTap: onVoice),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: Colors.white.withValues(alpha: .09)),
                color: Colors.white.withValues(alpha: .06),
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                onSubmitted: (_) => onSend(),
                style: const TextStyle(fontSize: 12.5, color: Colors.white),
                cursorColor: C.lavender,
                textInputAction: TextInputAction.send,
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  hintText: '说点什么…',
                  hintStyle: TextStyle(fontSize: 12.5, color: Color(0xFF7E7499)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _ComposerIcon(
            icon: Icons.sentiment_satisfied_alt_outlined,
            onTap: onEmoji,
          ),
          const SizedBox(width: 8),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              final enabled = value.text.trim().isNotEmpty;
              return GestureDetector(
                onTap: enabled ? onSend : null,
                child: Opacity(
                  opacity: enabled ? 1 : .4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(99),
                      gradient: C.gradHorizontal,
                    ),
                    child: const Text(
                      '发送',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ComposerIcon extends StatelessWidget {
  const _ComposerIcon({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: .06),
        ),
        child: Icon(icon, size: 17, color: const Color(0xFFCFC5EA)),
      ),
    );
  }
}
