import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme.dart';

/// 首页的「灵魂星球」场景：呼吸光晕、旋转星轨、漂浮的同频灵魂。
class PlanetScene extends StatefulWidget {
  const PlanetScene({super.key, required this.compact});

  final bool compact;

  @override
  State<PlanetScene> createState() => _PlanetSceneState();
}

class _PlanetSceneState extends State<PlanetScene>
    with TickerProviderStateMixin {
  late final AnimationController _spin;
  late final AnimationController _bob;
  late final AnimationController _breathe;
  late final AnimationController _sheen;

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 46),
    )..repeat();
    _bob = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5500),
    )..repeat();
    _breathe = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
    _sheen = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();
  }

  @override
  void dispose() {
    _spin.dispose();
    _bob.dispose();
    _breathe.dispose();
    _sheen.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final compact = widget.compact;
    final planetSize = compact ? 150.0 : 188.0;
    final haloSize = compact ? 250.0 : 330.0;
    final ring1 = compact ? 258.0 : 342.0;
    final ring2 = compact ? 198.0 : 264.0;
    final ring3 = compact ? 306.0 : 410.0;
    final k = planetSize / 188;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // 呼吸光晕
            AnimatedBuilder(
              animation: _breathe,
              builder: (context, child) {
                final t = Curves.easeInOut.transform(_breathe.value);
                return Transform.scale(
                  scale: 1 + .09 * t,
                  child: Opacity(opacity: 1 - .15 * t, child: child),
                );
              },
              child: Center(
                child: ImageFiltered(
                  imageFilter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                  child: Container(
                    width: haloSize,
                    height: haloSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          C.purple.withValues(alpha: .38),
                          C.pink.withValues(alpha: .14),
                          Colors.transparent,
                        ],
                        stops: const [0, .55, .72],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 静止星轨
            Center(
              child: Container(
                width: ring1,
                height: ring1,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: C.lavender.withValues(alpha: .16),
                  ),
                ),
              ),
            ),
            Center(
              child: Container(
                width: ring3,
                height: ring3,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: .06)),
                ),
              ),
            ),

            // 虚线星轨（旋转）
            AnimatedBuilder(
              animation: _spin,
              builder: (context, _) => Transform.rotate(
                angle: _spin.value * math.pi * 2,
                child: CustomPaint(
                  size: Size.square(ring2),
                  painter: _DashedCirclePainter(
                    color: C.pink.withValues(alpha: .16),
                    dashCount: 46,
                  ),
                ),
              ),
            ),

            // 两颗沿轨道运行的小星
            AnimatedBuilder(
              animation: _spin,
              builder: (context, _) {
                final t = _spin.value;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Transform.rotate(
                      angle: t * math.pi * 2 * (46 / 22),
                      child: SizedBox(
                        width: ring1,
                        height: ring1,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: _OrbitDot(color: const Color(0xFFC7B4FF)),
                        ),
                      ),
                    ),
                    Transform.rotate(
                      angle: -t * math.pi * 2 * (46 / 34),
                      child: SizedBox(
                        width: ring3,
                        height: ring3,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: _OrbitDot(
                            color: const Color(0xFFFF9CC0),
                            pink: true,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            // 星球本体
            SizedBox(
              width: planetSize,
              height: planetSize,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    center: Alignment(-.38, -.48),
                    radius: 1.0,
                    colors: [
                      Color(0xFFDCC8FF),
                      Color(0xFFA87CFF),
                      Color(0xFF7C4DFF),
                      Color(0xFF3D1E7A),
                      Color(0xFF1B0D38),
                    ],
                    stops: [0, .26, .48, .76, 1],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: C.purple.withValues(alpha: .5),
                      blurRadius: 60,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: C.pink.withValues(alpha: .18),
                      blurRadius: 130,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Stack(
                    children: [
                      // 内部明暗
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              center: const Alignment(-.62, -.72),
                              radius: 1.15,
                              colors: [
                                Colors.white.withValues(alpha: .10),
                                Colors.transparent,
                                Colors.black.withValues(alpha: .5),
                              ],
                              stops: const [0, .48, 1],
                            ),
                          ),
                        ),
                      ),

                      // 地表色块
                      _Blob(
                        left: 6 * k,
                        top: 34 * k,
                        width: 112 * k,
                        height: 66 * k,
                        color: Colors.white.withValues(alpha: .34),
                        blur: 6 * k,
                        angle: -20,
                      ),
                      _Blob(
                        right: 10 * k,
                        bottom: 44 * k,
                        width: 84 * k,
                        height: 52 * k,
                        color: const Color(0xFFFFA0CD).withValues(alpha: .36),
                        blur: 6 * k,
                        angle: 24,
                      ),
                      _Blob(
                        left: 66 * k,
                        bottom: 18 * k,
                        width: 60 * k,
                        height: 36 * k,
                        color: const Color(0xFF78F0E6).withValues(alpha: .3),
                        blur: 10 * k,
                      ),

                      // 旋转高光
                      Positioned.fill(
                        child: AnimatedBuilder(
                          animation: _sheen,
                          builder: (context, _) => Transform.rotate(
                            angle: _sheen.value * math.pi * 2,
                            child: CustomPaint(painter: _SheenPainter()),
                          ),
                        ),
                      ),

                      // 星球标签
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: (compact ? 11 : 15) * k,
                        child: Text(
                          'SOUL PLANET',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: (compact ? 7.5 : 8.5),
                            letterSpacing: 2.8,
                            color: Colors.white.withValues(alpha: .82),
                            fontWeight: FontWeight.w500,
                            shadows: C.textShadow,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 漂浮的灵魂
            AnimatedBuilder(
              animation: _bob,
              builder: (context, _) {
                final t = _bob.value;
                Widget bob({required double phase, required Widget child}) {
                  final dy = -5.5 * math.sin(2 * math.pi * (t + phase));
                  return Transform.translate(offset: Offset(0, dy), child: child);
                }

                return Stack(
                  children: [
                    Positioned(
                      left: compact ? 22 : 26,
                      top: compact ? 34 : 64,
                      child: bob(
                        phase: 0,
                        child: _Floater(
                          emoji: '🌙',
                          ava: 'a1',
                          label: '月见 · 92%',
                          compact: compact,
                        ),
                      ),
                    ),
                    Positioned(
                      right: compact ? 18 : 20,
                      top: compact ? 54 : 104,
                      child: bob(
                        phase: -1.8 / 5.5,
                        child: _Floater(
                          emoji: '🐟',
                          ava: 'a2',
                          label: '阿鲤 · 88%',
                          compact: compact,
                        ),
                      ),
                    ),
                    Positioned(
                      left: compact ? 30 : 38,
                      bottom: compact ? 30 : 60,
                      child: bob(
                        phase: -3.1 / 5.5,
                        child: _Floater(
                          emoji: '🌻',
                          ava: 'a3',
                          label: '小满 · 74%',
                          compact: compact,
                        ),
                      ),
                    ),
                    Positioned(
                      right: compact ? 36 : 44,
                      bottom: compact ? 18 : 36,
                      child: bob(
                        phase: -2.4 / 5.5,
                        child: _Floater(
                          emoji: '🎧',
                          ava: 'a4',
                          label: '阿岛 · 81%',
                          compact: compact,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _OrbitDot extends StatelessWidget {
  const _OrbitDot({required this.color, this.pink = false});

  final Color color;
  final bool pink;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: (pink ? C.pink : C.purple).withValues(alpha: .8),
            blurRadius: 12,
            spreadRadius: 3,
          ),
        ],
      ),
    );
  }
}

class _Floater extends StatelessWidget {
  const _Floater({
    required this.emoji,
    required this.ava,
    required this.label,
    required this.compact,
  });

  final String emoji;
  final String ava;
  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 32.0 : 38.0;
    final colors = C.avatarColors(ava);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: Colors.white.withValues(alpha: .35), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .5),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Text(
            emoji,
            style: TextStyle(fontSize: size * .45, height: 1),
          ),
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF0C0716).withValues(alpha: .6),
            borderRadius: BorderRadius.circular(99),
            border: Border.all(color: C.line),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: compact ? 9 : 9.5,
              color: const Color(0xFFD9D0F5),
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({
    this.left,
    this.top,
    this.right,
    this.bottom,
    required this.width,
    required this.height,
    required this.color,
    required this.blur,
    this.angle = 0,
  });

  final double? left;
  final double? top;
  final double? right;
  final double? bottom;
  final double width;
  final double height;
  final Color color;
  final double blur;
  final double angle;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      child: Transform.rotate(
        angle: angle * math.pi / 180,
        child: ImageFiltered(
          imageFilter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.all(Radius.elliptical(width, height)),
            ),
          ),
        ),
      ),
    );
  }
}

class _SheenPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..shader = const SweepGradient(
        startAngle: 0,
        endAngle: math.pi * 2,
        colors: [
          Colors.transparent,
          Color(0x24FFFFFF),
          Colors.transparent,
        ],
        stops: [0, .16, .34],
      ).createShader(rect);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DashedCirclePainter extends CustomPainter {
  _DashedCirclePainter({required this.color, required this.dashCount});

  final Color color;
  final int dashCount;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - .5;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final step = math.pi * 2 / dashCount;
    for (var i = 0; i < dashCount; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * step,
        step * .5,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.dashCount != dashCount;
}
