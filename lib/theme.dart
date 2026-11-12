import 'package:flutter/material.dart';

/// 星语 · 灵魂社交 App 视觉常量
/// 对应 soul-prototype.html 中的 :root 变量与通用渐变。
class C {
  C._();

  static const bg = Color(0xFF0A0612);
  static const stage = Color(0xFF07040F);
  static const panel = Color(0xFF150F24);
  static const panel2 = Color(0xFF1C1531);
  static const sheet = Color(0xFF1A1330);

  static const text = Color(0xFFF4F1FF);
  static const muted = Color(0xFF9A90B8);
  static const muted2 = Color(0xFF7E7499);
  static const dim = Color(0xFF5E5478);

  static const purple = Color(0xFF8B5CF6);
  static const violet = Color(0xFF6D5BFF);
  static const pink = Color(0xFFFF5C8A);
  static const pinkSoft = Color(0xFFFF9CC0);
  static const cyan = Color(0xFF38E1D6);
  static const green = Color(0xFF3BE38B);
  static const lavender = Color(0xFFC9B6FF);
  static const lavenderSoft = Color(0xFFD6C8F7);

  static const line = Color(0x17FFFFFF);
  static const lineSoft = Color(0x0FFFFFFF);
  static const card = Color(0x0BFFFFFF);

  static const dark = Color(0xFF0A0612);
  static const ringTrack = Color(0x17FFFFFF);

  static const gradColors = <Color>[
    Color(0xFF7C4DFF),
    Color(0xFFB45CFF),
    Color(0xFFFF4D8D),
  ];

  static const grad = LinearGradient(
    colors: gradColors,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradHorizontal = LinearGradient(
    colors: [violet, pink],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// 头像底色（对应 .ava.a1 ~ .a5）
  static const avatarGradients = <String, List<Color>>{
    'a1': [Color(0xFF6D5BFF), Color(0xFFB46BFF), Color(0xFFFF8FB1)],
    'a2': [Color(0xFF2ED3C6), Color(0xFF5B8CFF)],
    'a3': [Color(0xFFFFB347), Color(0xFFFF5C8A)],
    'a4': [Color(0xFF7CF0C4), Color(0xFF3BA7FF)],
    'a5': [Color(0xFFFF7AC8), Color(0xFF8B5CF6)],
  };

  static List<Color> avatarColors(String key) =>
      avatarGradients[key] ?? avatarGradients['a1']!;

  /// 瞬间 / 图片的 6 种拟真渐变（对应 .mcell.m1 ~ .m6）
  static Gradient mediaGradient(int index) {
    switch (index % 6) {
      case 0:
        return const RadialGradient(
          center: Alignment(-0.6, -0.7),
          radius: 1.2,
          colors: [Color(0xFFFFB48A), Color(0xFFB65C8E), Color(0xFF3A1A44)],
          stops: [0, .55, 1],
        );
      case 1:
        return const RadialGradient(
          center: Alignment(0.5, -0.6),
          radius: 1.2,
          colors: [Color(0xFF8EE9FF), Color(0xFF4C6BFF), Color(0xFF211246)],
          stops: [0, .52, 1],
        );
      case 2:
        return const RadialGradient(
          center: Alignment(-0.4, 0.6),
          radius: 1.2,
          colors: [Color(0xFFB8FFD8), Color(0xFF2FA98E), Color(0xFF0E2E3A)],
          stops: [0, .5, 1],
        );
      case 3:
        return const RadialGradient(
          center: Alignment(0.4, -0.4),
          radius: 1.2,
          colors: [Color(0xFFFFD1E6), Color(0xFFC065A8), Color(0xFF3C1533)],
          stops: [0, .52, 1],
        );
      case 4:
        return const RadialGradient(
          center: Alignment(-0.4, -0.6),
          radius: 1.2,
          colors: [Color(0xFFD8C4FF), Color(0xFF7B5BE0), Color(0xFF261650)],
          stops: [0, .52, 1],
        );
      default:
        return const RadialGradient(
          center: Alignment(0.3, 0.4),
          radius: 1.2,
          colors: [Color(0xFFFFE3A8), Color(0xFFD08A4E), Color(0xFF38220F)],
          stops: [0, .5, 1],
        );
    }
  }

  /// 广场三张配图（对应 .post-media.m1 ~ .m3）
  static Gradient postGradient(int index) {
    switch (index % 3) {
      case 0:
        return const RadialGradient(
          center: Alignment(-0.6, -0.7),
          radius: 1.2,
          colors: [Color(0xFFFF9A6B), Color(0xFFB04A8E), Color(0xFF2C1454)],
          stops: [0, .45, 1],
        );
      case 1:
        return const RadialGradient(
          center: Alignment(0.56, -0.64),
          radius: 1.2,
          colors: [Color(0xFF8EE9FF), Color(0xFF4C6BFF), Color(0xFF211246)],
          stops: [0, .46, 1],
        );
      default:
        return const RadialGradient(
          center: Alignment(-0.4, 0.6),
          radius: 1.2,
          colors: [Color(0xFFB8FFD8), Color(0xFF2FA98E), Color(0xFF0E2E3A)],
          stops: [0, .44, 1],
        );
    }
  }

  static const textShadow = <Shadow>[
    Shadow(color: Color(0x99000000), blurRadius: 8, offset: Offset(0, 1)),
  ];
}
