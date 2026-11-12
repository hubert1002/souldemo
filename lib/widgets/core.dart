import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';
import 'background.dart';

/* ------------------------------------------------------------------ */
/* 手机外框 / 状态栏                                                     */
/* ------------------------------------------------------------------ */

/// 标记当前内容是否运行在桌面手机外框中（外框内需要绘制假状态栏）。
class PhoneChrome extends InheritedWidget {
  const PhoneChrome({super.key, required this.framed, required super.child});

  final bool framed;

  static bool of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PhoneChrome>()?.framed ??
      false;

  @override
  bool updateShouldNotify(PhoneChrome oldWidget) => oldWidget.framed != framed;
}

/// 桌面 / 宽屏下的手机外框。窄屏直接全屏展示。
class PhoneFrame extends StatelessWidget {
  const PhoneFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final framed =
            constraints.maxWidth >= 500 && constraints.maxHeight >= 720;

        if (!framed) {
          return PhoneChrome(framed: false, child: child);
        }

        final screenHeight = math.min(844.0, constraints.maxHeight - 72);

        return PhoneChrome(
          framed: true,
          child: StageBackdrop(
            child: Center(
              child: SizedBox(
                width: 412,
                height: screenHeight + 22,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: Container(
                        padding: const EdgeInsets.all(11),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(56),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF3A3152),
                              Color(0xFF0C0915),
                              Color(0xFF100C1C),
                              Color(0xFF2A2244),
                            ],
                            stops: [0, .38, .7, 1],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: C.purple.withValues(alpha: .40),
                              blurRadius: 100,
                              spreadRadius: -18,
                              offset: const Offset(0, 42),
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: .55),
                              blurRadius: 40,
                              offset: const Offset(0, 18),
                            ),
                            BoxShadow(
                              color: Colors.white.withValues(alpha: .10),
                              blurRadius: 0,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(46),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              const ColoredBox(color: C.bg),
                              child,
                              Positioned(
                                top: 9,
                                left: 0,
                                right: 0,
                                child: IgnorePointer(
                                  child: Center(
                                    child: Container(
                                      width: 116,
                                      height: 25,
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 180,
                      right: -2,
                      child: _SideButton(height: 66),
                    ),
                    Positioned(
                      top: 258,
                      right: -2,
                      child: _SideButton(height: 40),
                    ),
                    Positioned(
                      top: 150,
                      left: -2,
                      child: _SideButton(height: 34),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SideButton extends StatelessWidget {
  const _SideButton({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 3,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2340),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class StatusArea extends StatelessWidget {
  const StatusArea({super.key});

  @override
  Widget build(BuildContext context) {
    if (!PhoneChrome.of(context)) {
      return SizedBox(height: MediaQuery.paddingOf(context).top);
    }

    return SizedBox(
      height: 46,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 6, 24, 0),
        child: Row(
          children: [
            const Text(
              '23:12',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: .2,
              ),
            ),
            const Spacer(),
            Row(
              children: const [
                _SignalBars(),
                SizedBox(width: 6),
                Icon(Icons.wifi, size: 14, color: Colors.white),
                SizedBox(width: 6),
                _BatteryIcon(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SignalBars extends StatelessWidget {
  const _SignalBars();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 10,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: const [
          _SignalBar(height: 3),
          _SignalBar(height: 5),
          _SignalBar(height: 7),
          _SignalBar(height: 10),
        ],
      ),
    );
  }
}

class _SignalBar extends StatelessWidget {
  const _SignalBar({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 2.5,
      height: height,
      margin: const EdgeInsets.only(left: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}

class _BatteryIcon extends StatelessWidget {
  const _BatteryIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 11,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 22,
            height: 11,
            padding: const EdgeInsets.all(1.5),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white.withValues(alpha: .75),
                width: 1.2,
              ),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: .72,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: -3,
            top: 3,
            child: Container(
              width: 2,
              height: 5,
              decoration: const BoxDecoration(
                color: Colors.white54,
                borderRadius: BorderRadius.horizontal(right: Radius.circular(2)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

double bottomInset(BuildContext context) =>
    PhoneChrome.of(context) ? 0 : MediaQuery.paddingOf(context).bottom;

/* ------------------------------------------------------------------ */
/* 通用按钮 / 头像                                                      */
/* ------------------------------------------------------------------ */

class GradientText extends StatelessWidget {
  const GradientText(this.text, {super.key, required this.style});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) =>
          C.grad.createShader(Offset.zero & bounds.size),
      child: Text(text, style: style.copyWith(color: Colors.white)),
    );
  }
}

class SoulAvatar extends StatelessWidget {
  const SoulAvatar({
    super.key,
    required this.emoji,
    required this.ava,
    this.size = 42,
    this.online = false,
  });

  final String emoji;
  final String ava;
  final double size;
  final bool online;

  @override
  Widget build(BuildContext context) {
    final colors = C.avatarColors(ava);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .4),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: colors.last.withValues(alpha: .18),
                  blurRadius: 14,
                ),
              ],
            ),
            child: Text(
              emoji,
              style: TextStyle(fontSize: size * .45, height: 1),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: .18),
                  ),
                ),
              ),
            ),
          ),
          if (online)
            Positioned(
              right: 0,
              bottom: size * .02,
              child: Container(
                width: size * .24,
                height: size * .24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: C.green,
                  border: Border.all(color: const Color(0xFF0B0714), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: C.green.withValues(alpha: .55),
                      blurRadius: 6,
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

class ScoreRing extends StatelessWidget {
  const ScoreRing({
    super.key,
    required this.score,
    this.size = 58,
    this.stroke = 3,
    this.child,
  });

  final double score;
  final double size;
  final double stroke;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(size),
            painter: _RingPainter(
              progress: (score / 100).clamp(0.0, 1.0),
              strokeWidth: stroke,
            ),
          ),
          ?child,
        ],
      ),
    );
  }
}

class SoulRingAvatar extends StatelessWidget {
  const SoulRingAvatar({
    super.key,
    required this.emoji,
    required this.ava,
    required this.score,
  });

  final String emoji;
  final String ava;
  final int score;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 58,
      height: 58,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ScoreRing(score: score.toDouble(), size: 58, stroke: 3),
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF140E22),
            ),
            child: Center(
              child: SoulAvatar(emoji: emoji, ava: ava, size: 46),
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress, required this.strokeWidth});

  final double progress;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = C.ringTrack;
    canvas.drawCircle(center, radius, track);

    if (progress <= 0) return;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = const SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: math.pi * 3 / 2,
        colors: [
          Color(0xFFFF5C8A),
          Color(0xFFA96BFF),
          Color(0xFF8B5CF6),
          Color(0xFF8B5CF6),
        ],
        stops: [0, .55, .92, 1],
      ).createShader(rect);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.strokeWidth != strokeWidth;
}

class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    super.key,
    required this.child,
    this.onTap,
    this.size = 38,
    this.showBorder = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double size;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: .05),
      shape: CircleBorder(
        side: showBorder ? const BorderSide(color: C.line) : BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Center(child: child),
        ),
      ),
    );
  }
}

class BackButtonCircle extends StatelessWidget {
  const BackButtonCircle({super.key, this.onTap, this.size = 32});

  final VoidCallback? onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: .06),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap ?? () => Navigator.of(context).maybePop(),
        child: SizedBox(
          width: size,
          height: size,
          child: const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 2),
              child: Text(
                '‹',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  height: 1,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/* ------------------------------------------------------------------ */
/* 页面骨架                                                             */
/* ------------------------------------------------------------------ */

class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.trailing,
    this.showBack = true,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final Widget? trailing;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0x0FFFFFFF))),
      ),
      child: Row(
        children: [
          if (showBack) ...[
            BackButtonCircle(onTap: onBack),
            const SizedBox(width: 10),
          ],
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: C.text,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                subtitle!,
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 10.5, color: C.muted),
              ),
            ),
          ],
          if (trailing != null) ...[
            if (subtitle == null) const Spacer(),
            trailing!,
          ],
        ],
      ),
    );
  }
}

class SectionHead extends StatelessWidget {
  const SectionHead({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
    this.onAction,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final String? action;
  final VoidCallback? onAction;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 12),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: C.text,
            ),
          ),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Text(
                subtitle!,
                style: const TextStyle(fontSize: 11.5, color: C.muted),
              ),
            ),
          const Spacer(),
          ?trailing,
          if (action != null)
            GestureDetector(
              onTap: onAction,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: Text(
                  action!,
                  style: const TextStyle(fontSize: 11.5, color: C.muted),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class HeartProgress extends StatelessWidget {
  const HeartProgress({
    super.key,
    required this.heart,
    required this.target,
    this.height = 5,
  });

  final int heart;
  final int target;
  final double height;

  @override
  Widget build(BuildContext context) {
    final pct = target == 0 ? 0.0 : (heart / target).clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: Colors.white.withValues(alpha: .08)),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: pct),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: value,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(99),
                      gradient: C.gradHorizontal,
                      boxShadow: [
                        BoxShadow(
                          color: C.pink.withValues(alpha: .45),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TraitBar extends StatelessWidget {
  const TraitBar({super.key, required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          SizedBox(
            width: 52,
            child: Text(
              label,
              style: const TextStyle(fontSize: 11, color: Color(0xFFC9BFE6)),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: SizedBox(
                height: 6,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(color: Colors.white.withValues(alpha: .08)),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: value / 100),
                      duration: const Duration(seconds: 1),
                      curve: Curves.easeOutCubic,
                      builder: (context, v, _) => Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: v,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(99),
                              gradient: C.gradHorizontal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            width: 26,
            child: Text(
              '$value',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: C.muted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AppSwitch extends StatelessWidget {
  const AppSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        width: 41,
        height: 23,
        padding: const EdgeInsets.all(2.5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(99),
          gradient: value ? C.gradHorizontal : null,
          color: value ? null : Colors.white.withValues(alpha: .16),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .35),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* ------------------------------------------------------------------ */
/* Toast / 底部操作面板 / 路由                                           */
/* ------------------------------------------------------------------ */

void showToast(BuildContext context, String message) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  showToastOn(messenger, message);
}

void showToastOn(ScaffoldMessengerState messenger, String message) {
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFFEFE9FF),
          fontSize: 11.5,
          height: 1.4,
        ),
      ),
      backgroundColor: const Color(0xF21E1634),
      elevation: 12,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.fromLTRB(36, 0, 36, 108),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      duration: const Duration(milliseconds: 1900),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(99),
        side: const BorderSide(color: Color(0x47B48CFF)),
      ),
    ),
  );
}

class SheetAction {
  const SheetAction({
    required this.label,
    this.danger = false,
    this.onTap,
  });

  final String label;
  final bool danger;
  final VoidCallback? onTap;
}

Future<void> showAppSheet(
  BuildContext context, {
  required String title,
  required List<SheetAction> actions,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0xA604020A),
    isScrollControlled: true,
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
          10,
          0,
          10,
          10 + bottomInset(sheetContext),
        ),
        child: Material(
          color: C.sheet,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: C.line),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 6),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11, color: C.muted),
                  ),
                ),
                for (final action in actions)
                  InkWell(
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      if (action.onTap != null) {
                        Future<void>.delayed(
                          const Duration(milliseconds: 80),
                          action.onTap!,
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        child: Text(
                          action.label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13.5,
                            color: action.danger ? const Color(0xFFFF6F8E) : const Color(0xFFEDE7FB),
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 6),
                InkWell(
                  onTap: () => Navigator.of(sheetContext).pop(),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .07),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '取消',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12.5, color: Color(0xFFA99FC4)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Route<T> slideRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(curved),
        child: FadeTransition(opacity: animation, child: child),
      );
    },
  );
}

class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    this.onTap,
    this.height,
    this.radius = 16,
    this.fontSize = 14,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
  });

  final String label;
  final VoidCallback? onTap;
  final double? height;
  final double radius;
  final double fontSize;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: height,
        padding: height == null ? padding : null,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
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
        child: Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: .2,
          ),
        ),
      ),
    );
  }
}

class GhostButton extends StatelessWidget {
  const GhostButton({
    super.key,
    required this.label,
    this.onTap,
    this.height,
    this.radius = 16,
    this.fontSize = 12.5,
  });

  final String label;
  final VoidCallback? onTap;
  final double? height;
  final double radius;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: height,
        padding: height == null
            ? const EdgeInsets.symmetric(horizontal: 14, vertical: 12)
            : null,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          color: Colors.white.withValues(alpha: .05),
          border: Border.all(color: C.line),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: fontSize, color: const Color(0xFFCFC5EA)),
        ),
      ),
    );
  }
}

class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 420),
  });

  final Widget child;
  final Duration duration;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..forward();
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _offset = Tween<Offset>(
      begin: const Offset(0, .045),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _offset, child: widget.child),
    );
  }
}
