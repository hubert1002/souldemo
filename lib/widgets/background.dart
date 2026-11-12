import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';

/// 页面背景：深空底色 + 顶部紫色光晕 + 底部粉色光晕 + 闪烁星尘。
class AppBackdrop extends StatelessWidget {
  const AppBackdrop({super.key, required this.child, this.pinkGlow = true});

  final Widget child;
  final bool pinkGlow;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: C.bg),
        CustomPaint(painter: _GlowPainter(pinkGlow: pinkGlow)),
        const IgnorePointer(child: RepaintBoundary(child: Starfield())),
        child,
      ],
    );
  }
}

/// 桌面端手机外框背后的舞台背景。
class StageBackdrop extends StatelessWidget {
  const StageBackdrop({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: C.stage),
        CustomPaint(painter: _StageGlowPainter()),
        const IgnorePointer(child: RepaintBoundary(child: Starfield(starCount: 70))),
        ?child,
      ],
    );
  }
}

class Starfield extends StatefulWidget {
  const Starfield({super.key, this.starCount = 44});

  final int starCount;

  @override
  State<Starfield> createState() => _StarfieldState();
}

class _StarfieldState extends State<Starfield>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Star> _stars;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    )..repeat(reverse: true);
    final rnd = math.Random(42);
    _stars = List.generate(widget.starCount, (i) {
      final big = rnd.nextDouble() > .82;
      return _Star(
        x: rnd.nextDouble(),
        y: rnd.nextDouble(),
        radius: big ? 1.1 + rnd.nextDouble() * .5 : .5 + rnd.nextDouble() * .6,
        base: .25 + rnd.nextDouble() * .45,
        phase: rnd.nextDouble() * math.pi * 2,
        speed: .6 + rnd.nextDouble() * .9,
      );
    });
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
        return CustomPaint(
          painter: _StarPainter(
            stars: _stars,
            t: _controller.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _Star {
  const _Star({
    required this.x,
    required this.y,
    required this.radius,
    required this.base,
    required this.phase,
    required this.speed,
  });

  final double x;
  final double y;
  final double radius;
  final double base;
  final double phase;
  final double speed;
}

class _StarPainter extends CustomPainter {
  _StarPainter({required this.stars, required this.t});

  final List<_Star> stars;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final s in stars) {
      final twinkle =
          (0.5 + 0.5 * math.sin(t * math.pi * 2 * s.speed + s.phase));
      final alpha = (s.base * (.55 + .45 * twinkle)).clamp(0.0, 1.0);
      paint.color = Colors.white.withValues(alpha: alpha);
      if (s.radius > 1.05) {
        paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.6);
      } else {
        paint.maskFilter = null;
      }
      canvas.drawCircle(
        Offset(s.x * size.width, s.y * size.height),
        s.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StarPainter oldDelegate) => oldDelegate.t != t;
}

class _GlowPainter extends CustomPainter {
  _GlowPainter({required this.pinkGlow});

  final bool pinkGlow;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final top = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -1.12),
        radius: 1.0,
        colors: [
          C.purple.withValues(alpha: .24),
          C.purple.withValues(alpha: .06),
          Colors.transparent,
        ],
        stops: const [0, .55, 1],
      ).createShader(rect);
    canvas.drawRect(rect, top);

    if (pinkGlow) {
      final bottom = Paint()
        ..shader = RadialGradient(
          center: const Alignment(.78, .92),
          radius: .85,
          colors: [
            C.pink.withValues(alpha: .12),
            Colors.transparent,
          ],
        ).createShader(rect);
      canvas.drawRect(rect, bottom);
    }
  }

  @override
  bool shouldRepaint(covariant _GlowPainter oldDelegate) =>
      oldDelegate.pinkGlow != pinkGlow;
}

class _StageGlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final left = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-.64, -.84),
        radius: .9,
        colors: [C.purple.withValues(alpha: .20), Colors.transparent],
      ).createShader(rect);
    canvas.drawRect(rect, left);

    final bottom = Paint()
      ..shader = RadialGradient(
        center: const Alignment(.72, .84),
        radius: .8,
        colors: [C.pink.withValues(alpha: .10), Colors.transparent],
      ).createShader(rect);
    canvas.drawRect(rect, bottom);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
