import 'package:flutter/material.dart';

import '../state.dart';
import '../theme.dart';
import '../widgets/core.dart';
import 'edit_profile_screen.dart';
import 'friends_screen.dart';
import 'moment_screen.dart';
import 'settings_screen.dart';

class MeScreen extends StatelessWidget {
  const MeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final me = state.me;

    return ListView(
      padding: EdgeInsets.fromLTRB(18, 8, 18, 110 + bottomInset(context)),
      physics: const BouncingScrollPhysics(),
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: C.line),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .035),
                      gradient: RadialGradient(
                        center: const Alignment(.7, -1.0),
                        radius: 1.2,
                        colors: [
                          C.pink.withValues(alpha: .22),
                          Colors.transparent,
                        ],
                        stops: const [0, .58],
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(-1.0, -.8),
                        radius: 1.2,
                        colors: [
                          C.purple.withValues(alpha: .3),
                          Colors.transparent,
                        ],
                        stops: const [0, .6],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(17, 19, 17, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SoulAvatar(emoji: me.emoji, ava: me.ava, size: 64),
                      const SizedBox(height: 10),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 7,
                        runSpacing: 4,
                        children: [
                          Text(
                            me.name,
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w600,
                              color: C.text,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: .14),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: const Text(
                              '24 · 上海',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFFEBD9FF),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          GradientText(
                            'INFJ · 深海观星者',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFD3C4F5),
                            ),
                          ),
                          const Text(
                            ' · 灵魂编号 88213047',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFFD3C4F5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        me.sig,
                        style: const TextStyle(
                          fontSize: 11.5,
                          height: 1.6,
                          color: Color(0xFFB9AED8),
                        ),
                      ),
                      const SizedBox(height: 9),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final tag in me.tags)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: C.purple.withValues(alpha: .16),
                                borderRadius: BorderRadius.circular(99),
                                border: Border.all(
                                  color: const Color(0xFFB48CFF)
                                      .withValues(alpha: .28),
                                ),
                              ),
                              child: Text(
                                tag,
                                style: const TextStyle(
                                  fontSize: 9.5,
                                  color: C.lavender,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        '注册 214 天 · 已点亮 6 段灵魂关系',
                        style: TextStyle(fontSize: 10.5, color: Color(0xFF8B80A8)),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 15),
                        padding: const EdgeInsets.only(top: 12),
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Color(0x17FFFFFF)),
                          ),
                        ),
                        child: Row(
                          children: const [
                            _MeStat(value: '128', label: '灵魂匹配'),
                            _MeStat(value: '24', label: '发布瞬间', divider: true),
                            _MeStat(value: '6', label: '密友'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 14,
                  right: 14,
                  child: GlassIconButton(
                    size: 32,
                    onTap: () => Navigator.of(context).push(
                      slideRoute(const EditProfileScreen()),
                    ),
                    child: const Text(
                      '✎',
                      style: TextStyle(fontSize: 13, color: Color(0xFFE8E2FF)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SectionHead(
          title: '我的灵魂画像',
          action: '完整报告 ›',
          onAction: () => showToast(context, '完整报告已生成：你是「夜间高共情型」'),
        ),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: C.line),
            color: Colors.white.withValues(alpha: .03),
          ),
          child: const Column(
            children: [
              TraitBar(label: '共情力', value: 92),
              TraitBar(label: '好奇心', value: 88),
              TraitBar(label: '夜行性', value: 95),
              TraitBar(label: '社交电量', value: 34),
            ],
          ),
        ),
        const SectionHead(title: '常用'),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: C.line),
            color: Colors.white.withValues(alpha: .03),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Column(
              children: [
                _MenuRow(
                  icon: '🧬',
                  label: '灵魂鉴定',
                  onTap: () => showToast(context, '灵魂鉴定：每 30 天可重测一次'),
                ),
                _MenuRow(
                  icon: '✧',
                  label: '我的瞬间',
                  onTap: () => Navigator.of(context).push(
                    slideRoute(const MomentScreen(friendId: 'me')),
                  ),
                ),
                _MenuRow(
                  icon: '🎁',
                  label: '礼物背包',
                  onTap: () => showToast(context, '已送出 12 份礼物'),
                ),
                _MenuRow(
                  icon: '💜',
                  label: '密友关系',
                  onTap: () => Navigator.of(context).push(
                    slideRoute(const FriendsScreen(filter: 'close')),
                  ),
                ),
                _MenuRow(
                  icon: '⚙',
                  label: '设置',
                  onTap: () => Navigator.of(context).push(
                    slideRoute(const SettingsScreen()),
                  ),
                  divider: false,
                ),
              ],
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 22, bottom: 4),
          child: Text(
            '星语 · 让同频的人先遇见 ✦',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, color: Color(0xFF5E5478)),
          ),
        ),
      ],
    );
  }
}

class _MeStat extends StatelessWidget {
  const _MeStat({
    required this.value,
    required this.label,
    this.divider = false,
  });

  final String value;
  final String label;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: divider
              ? const Border(left: BorderSide(color: Color(0x12FFFFFF)))
              : null,
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: C.text,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Color(0xFFA99FC4)),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.divider = true,
  });

  final String icon;
  final String label;
  final VoidCallback onTap;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          border: divider
              ? const Border(top: BorderSide(color: Color(0x0FFFFFFF)))
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: C.purple.withValues(alpha: .18),
              ),
              child: Text(icon, style: const TextStyle(fontSize: 13)),
            ),
            const SizedBox(width: 11),
            Text(
              label,
              style: const TextStyle(fontSize: 12.5, color: Color(0xFFEDE7FB)),
            ),
            const Spacer(),
            const Text(
              '›',
              style: TextStyle(fontSize: 14, color: Color(0xFF6F6590)),
            ),
          ],
        ),
      ),
    );
  }
}
