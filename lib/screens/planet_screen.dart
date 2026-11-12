import 'package:flutter/material.dart';

import '../state.dart';
import '../theme.dart';
import '../widgets/core.dart';
import '../widgets/planet_scene.dart';
import 'chat_screen.dart';
import 'match_overlay.dart';

class PlanetScreen extends StatelessWidget {
  const PlanetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final compact = MediaQuery.sizeOf(context).height < 760;

    return ListView(
      padding: EdgeInsets.only(bottom: 110 + bottomInset(context)),
      physics: const BouncingScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 6, 18, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '晚上好，星野 ✦',
                          style: TextStyle(
                            fontSize: 12,
                            color: C.muted,
                            letterSpacing: .5,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            const Text(
                              '今晚想和谁',
                              style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -.4,
                                color: C.text,
                              ),
                            ),
                            GradientText(
                              '同频',
                              style: const TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -.4,
                              ),
                            ),
                            const Text(
                              '？',
                              style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -.4,
                                color: C.text,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  GlassIconButton(
                    onTap: () => showToast(context, '你有 3 条新的灵魂来信'),
                    child: const Text('🔔', style: TextStyle(fontSize: 15)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const _LiveStrip(),
            ],
          ),
        ),
        SizedBox(
          height: compact ? 220 : 352,
          child: PlanetScene(compact: compact),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 6),
          child: Column(
            children: [
              _MatchButton(
                onTap: () async {
                  final start = await showMatchOverlay(context);
                  if (!context.mounted) return;
                  if (start) {
                    Navigator.of(context).push(
                      slideRoute(ChatScreen(chatId: 'yuejian')),
                    );
                    Future<void>.delayed(
                      const Duration(milliseconds: 420),
                      () {
                        if (context.mounted) {
                          showToast(context, '已进入聊天，用破冰话题开场吧 ✦');
                        }
                      },
                    );
                  }
                },
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.mic_none_rounded,
                      label: '语音匹配',
                      onTap: () => showToast(context, '正在接入「深夜电台」语音星球…'),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.celebration_outlined,
                      label: '群聊派对',
                      onTap: () {
                        Navigator.of(context).push(
                          slideRoute(ChatScreen(chatId: 'party')),
                        );
                        Future<void>.delayed(
                          const Duration(milliseconds: 380),
                          () {
                            if (context.mounted) {
                              showToast(context, '已进入群聊派对 · 12 人在线');
                            }
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.auto_awesome_outlined,
                      label: '灵魂瞬间',
                      onTap: () {
                        state.setTab(1);
                        showToast(context, '已进入广场 · 看看今天的同频瞬间');
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LiveStrip extends StatelessWidget {
  const _LiveStrip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: C.line),
        gradient: LinearGradient(
          colors: [
            C.cyan.withValues(alpha: .1),
            C.purple.withValues(alpha: .08),
          ],
        ),
      ),
      child: Row(
        children: [
          const _LiveDot(),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFFBFD9E8),
                  height: 1.4,
                ),
                children: const [
                  TextSpan(text: '此刻 '),
                  TextSpan(
                    text: '2,481',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ' 个灵魂在线 · 你的灵魂浓度 '),
                  TextSpan(
                    text: '87%',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
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

class _LiveDot extends StatefulWidget {
  const _LiveDot();

  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        return Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: C.cyan,
            boxShadow: [
              BoxShadow(
                color: C.cyan.withValues(alpha: .16 * (1 - t)),
                spreadRadius: 4 + 8 * t,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: .045),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: C.line),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 21, color: const Color(0xFFD9CBF8)),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Color(0xFFDCD4F4)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MatchButton extends StatefulWidget {
  const _MatchButton({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_MatchButton> createState() => _MatchButtonState();
}

class _MatchButtonState extends State<_MatchButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shine;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _shine = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..repeat();
  }

  @override
  void dispose() {
    _shine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? .982 : 1,
        duration: const Duration(milliseconds: 160),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: C.grad,
            boxShadow: [
              BoxShadow(
                color: C.purple.withValues(alpha: .45),
                blurRadius: 40,
                offset: const Offset(0, 18),
                spreadRadius: -18,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: Colors.white.withValues(alpha: .28),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 17,
                        vertical: 15,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: .2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              '✦',
                              style: TextStyle(fontSize: 17, color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 13),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '灵魂匹配',
                                  style: TextStyle(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: .1,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  '按人格、兴趣与此刻心情，找到同频的人',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xDBFFFFFF),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0x470A0614),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: const Text(
                              '开始',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 掠过的光
                    AnimatedBuilder(
                      animation: _shine,
                      builder: (context, _) {
                        final t = _shine.value;
                        if (t < .6) return const SizedBox.shrink();
                        final p = (t - .6) / .4;
                        final left =
                            -120 + p * (constraints.maxWidth + 240);
                        return Positioned(
                          left: left,
                          top: -40,
                          bottom: -40,
                          width: 84,
                          child: Transform.rotate(
                            angle: .32,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.white.withValues(alpha: .42),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
