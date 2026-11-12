import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/core.dart';

Future<bool> showMatchOverlay(BuildContext context) async {
  final result = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: false,
    barrierLabel: '灵魂匹配',
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) =>
        const _MatchOverlay(),
    transitionBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(opacity: animation, child: child),
  );
  return result ?? false;
}

class _MatchOverlay extends StatefulWidget {
  const _MatchOverlay();

  @override
  State<_MatchOverlay> createState() => _MatchOverlayState();
}

class _MatchOverlayState extends State<_MatchOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _ripple;
  late final AnimationController _bob;

  Timer? _scanTimer;
  Timer? _matchTimer;
  int _scanned = 1204;
  bool _result = false;
  int _round = 0;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _ripple = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();
    _bob = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
    _startMatch();
  }

  void _startMatch() {
    _scanTimer?.cancel();
    _matchTimer?.cancel();
    setState(() {
      _result = false;
      _round++;
      _scanned = 1180 + _random.nextInt(90);
    });
    _scanTimer = Timer.periodic(const Duration(milliseconds: 130), (_) {
      if (!mounted) return;
      setState(() => _scanned += 9 + _random.nextInt(26));
    });
    _matchTimer = Timer(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      _scanTimer?.cancel();
      setState(() => _result = true);
    });
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    _matchTimer?.cancel();
    _ripple.dispose();
    _bob.dispose();
    super.dispose();
  }

  String _fmt(int n) => n.toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (_) => ',',
      );

  @override
  Widget build(BuildContext context) {
    final closeTop =
        (PhoneChrome.of(context) ? 46.0 : MediaQuery.paddingOf(context).top) + 8;

    return Material(
      color: Colors.transparent,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRect(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(color: const Color(0xF206030E)),
            ),
          ),
          // 顶部紫色光晕
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -.36),
                radius: .78,
                colors: [
                  C.purple.withValues(alpha: .42),
                  Colors.transparent,
                ],
                stops: const [0, .68],
              ),
            ),
          ),
          const Positioned(top: 0, left: 0, right: 0, child: StatusArea()),
          Positioned(
            top: closeTop,
            right: 20,
            child: GlassIconButton(
              size: 34,
              onTap: () => Navigator.of(context).pop(false),
              child: const Text(
                '✕',
                style: TextStyle(fontSize: 13, color: Color(0xFFCFC5EA)),
              ),
            ),
          ),
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(26, 70, 26, 26),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: math.max(0, constraints.maxHeight - 96),
                    ),
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 380),
                        switchInCurve: Curves.easeOutCubic,
                        transitionBuilder: (child, animation) => FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(
                            scale: Tween<double>(begin: .96, end: 1)
                                .animate(animation),
                            child: child,
                          ),
                        ),
                        child: _result
                            ? _buildResult()
                            : _buildScanning(),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanning() {
    return Column(
      key: const ValueKey('scanning'),
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 210,
          height: 210,
          child: Stack(
            alignment: Alignment.center,
            children: [
              for (var i = 0; i < 3; i++)
                AnimatedBuilder(
                  animation: _ripple,
                  builder: (context, _) {
                    final phase = (_ripple.value + i * .85 / 2.6) % 1;
                    final opacity = phase < .25
                        ? phase / .25 * .95
                        : .95 * (1 - (phase - .25) / .75);
                    return Transform.scale(
                      scale: .35 + .65 * phase,
                      child: Container(
                        width: 210,
                        height: 210,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFB48CFF)
                                .withValues(alpha: opacity.clamp(0, 1)),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              AnimatedBuilder(
                animation: _bob,
                builder: (context, child) => Transform.translate(
                  offset: Offset(
                    0,
                    -7 * math.sin(2 * math.pi * _bob.value),
                  ),
                  child: child,
                ),
                child: Container(
                  width: 96,
                  height: 96,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: C.grad,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFA06EFF).withValues(alpha: .8),
                        blurRadius: 50,
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white.withValues(alpha: .25),
                    ),
                  ),
                  child: const Text(
                    '✦',
                    style: TextStyle(fontSize: 30, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 26),
        const Text(
          '正在寻找同频的灵魂…',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: .4,
            color: C.text,
          ),
        ),
        const SizedBox(height: 9),
        Text(
          '已扫描 ${_fmt(_scanned)} 个灵魂',
          style: const TextStyle(
            fontSize: 11.5,
            color: C.muted,
            letterSpacing: .4,
          ),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          alignment: WrapAlignment.center,
          children: [
            for (final tag in const ['INFJ', '夜行生物', '独立音乐', '上海'])
              _Pill(tag),
          ],
        ),
      ],
    );
  }

  Widget _buildResult() {
    return Column(
      key: ValueKey('result-$_round'),
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          '匹配成功 ✦ 灵魂契合度',
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 2.6,
            color: Color(0xFFD9C9FF),
          ),
        ),
        const SizedBox(height: 4),
        TweenAnimationBuilder<int>(
          tween: IntTween(begin: 0, end: 92),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutCubic,
          builder: (context, value, _) {
            return ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (bounds) =>
                  C.grad.createShader(Offset.zero & bounds.size),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '$value',
                      style: const TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.w800,
                        height: 1,
                        letterSpacing: -2,
                        color: Colors.white,
                      ),
                    ),
                    const TextSpan(
                      text: '%',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: C.purple.withValues(alpha: .25),
              width: 4,
            ),
          ),
          child: const SoulAvatar(
            emoji: '🌙',
            ava: 'a1',
            size: 74,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          '月见 · 24',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: .5,
            color: C.text,
          ),
        ),
        const SizedBox(height: 9),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          alignment: WrapAlignment.center,
          children: [
            for (final tag in const ['INFJ', '夜行生物', '独立音乐', '上海'])
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: C.purple.withValues(alpha: .2),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(
                    color: const Color(0xFFB48CFF).withValues(alpha: .35),
                  ),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: C.lavenderSoft,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        const SizedBox(
          width: 250,
          child: Text(
            '“凌晨三点的城市，和白天的不是同一座。”',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              height: 1.7,
              color: Color(0xFFB8AED4),
            ),
          ),
        ),
        const SizedBox(height: 24),
        GradientButton(
          label: '打个招呼，开始聊天',
          radius: 16,
          onTap: () => Navigator.of(context).pop(true),
        ),
        const SizedBox(height: 9),
        GhostButton(
          label: '再匹配一次',
          radius: 16,
          onTap: _startMatch,
        ),
        const SizedBox(height: 14),
        const Text(
          '匹配结果每天 3 次 · 已用 1 次',
          style: TextStyle(fontSize: 10, color: Color(0xFF6F6590)),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: C.line),
        color: Colors.white.withValues(alpha: .045),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 10.5, color: Color(0xFFC4B6E6)),
      ),
    );
  }
}
