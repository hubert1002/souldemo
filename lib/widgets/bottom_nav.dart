import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme.dart';
import 'core.dart';

/// 底部 Tab 栏，带毛玻璃与渐变描边图标。
class BottomNav extends StatelessWidget {
  const BottomNav({
    super.key,
    required this.index,
    required this.showMessageDot,
    required this.onTap,
  });

  final int index;
  final bool showMessageDot;
  final ValueChanged<int> onTap;

  static const _items = [
    ('planet', '星球', Icons.circle),
    ('plaza', '广场', Icons.circle),
    ('messages', '消息', Icons.circle),
    ('me', '我的', Icons.circle),
  ];

  @override
  Widget build(BuildContext context) {
    final bottom = bottomInset(context);
    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          height: 78 + bottom,
          padding: EdgeInsets.fromLTRB(10, 8, 10, 14 + bottom),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xA80A0612), Color(0xF50A0612)],
              stops: [0, .42],
            ),
            border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: .07)),
            ),
          ),
          child: Row(
            children: [
              for (var i = 0; i < _items.length; i++)
                Expanded(
                  child: _NavItem(
                    kind: _items[i].$1,
                    label: _items[i].$2,
                    active: index == i,
                    showDot: i == 2 && showMessageDot,
                    onTap: () => onTap(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.kind,
    required this.label,
    required this.active,
    required this.showDot,
    required this.onTap,
  });

  final String kind;
  final String label;
  final bool active;
  final bool showDot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: CustomPaint(
                  painter: _TabGlyphPainter(kind: kind, active: active),
                ),
              ),
              if (showDot)
                Positioned(
                  top: -2,
                  right: -4,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: C.pink,
                      boxShadow: [
                        BoxShadow(
                          color: C.pink.withValues(alpha: .6),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 9.5,
              height: 1,
              color: active ? Colors.white : const Color(0xFF6E6489),
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          const SizedBox(height: 3),
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? const Color(0xFFC6A8FF) : Colors.transparent,
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: const Color(0xFFC6A8FF).withValues(alpha: .9),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _TabGlyphPainter extends CustomPainter {
  _TabGlyphPainter({required this.kind, required this.active});

  final String kind;
  final bool active;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 24, size.height / 24);

    if (active) {
      final glow = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = C.lavender.withValues(alpha: .75)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      _draw(canvas, glow);
    }

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    if (active) {
      paint.shader = const LinearGradient(
        colors: [Color(0xFFC9A8FF), Color(0xFFB46BFF), Color(0xFFFF7FB0)],
      ).createShader(const Rect.fromLTWH(0, 0, 24, 24));
    } else {
      paint.color = const Color(0xFF6E6489);
    }
    _draw(canvas, paint);
    canvas.restore();
  }

  void _draw(Canvas canvas, Paint paint) {
    switch (kind) {
      case 'planet':
        canvas.drawCircle(const Offset(12, 12), 4.6, paint);
        canvas.save();
        canvas.translate(12, 12);
        canvas.rotate(-22 * 3.1415926 / 180);
        canvas.drawOval(
          Rect.fromCenter(center: Offset.zero, width: 20, height: 8.4),
          paint,
        );
        canvas.restore();
        break;
      case 'plaza':
        canvas.drawCircle(const Offset(12, 12), 8.4, paint);
        final path = Path()
          ..moveTo(15.2, 8.8)
          ..lineTo(13.4, 13.4)
          ..lineTo(8.8, 15.2)
          ..lineTo(10.6, 10.6)
          ..close();
        canvas.drawPath(path, paint);
        break;
      case 'messages':
        final path = Path()
          ..moveTo(20.6, 11.4)
          ..cubicTo(20.6, 15.9, 16.5, 19.6, 11.8, 19.6)
          ..cubicTo(10.3, 19.6, 8.9, 19.2, 8.1, 18.8)
          ..lineTo(3.4, 20.4)
          ..lineTo(5.0, 15.9)
          ..cubicTo(4.2, 14.6, 3.8, 13.1, 3.8, 11.6)
          ..cubicTo(3.8, 7.0, 7.9, 3.4, 12.2, 3.4)
          ..cubicTo(16.9, 3.4, 20.6, 7.0, 20.6, 11.4)
          ..close();
        canvas.drawPath(path, paint);
        break;
      default:
        canvas.drawCircle(const Offset(12, 8.2), 3.6, paint);
        final path = Path()
          ..moveTo(4.8, 20)
          ..arcToPoint(
            const Offset(19.2, 20),
            radius: const Radius.circular(7.2),
            clockwise: false,
          );
        canvas.drawPath(path, paint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _TabGlyphPainter oldDelegate) =>
      oldDelegate.active != active || oldDelegate.kind != kind;
}
