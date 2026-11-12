import 'package:flutter/material.dart';

import '../state.dart';
import '../theme.dart';
import '../widgets/background.dart';
import '../widgets/core.dart';
import 'edit_profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _strangerMessages = true;
  bool _showOnline = true;
  bool _hideVisits = false;
  bool _notifications = true;
  String _cache = '12.4 MB';

  void _toggle(String label, bool value) {
    showToast(context, '$label ${value ? '已开启' : '已关闭'}');
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final me = state.me;

    return Scaffold(
      backgroundColor: C.bg,
      body: AppBackdrop(
        pinkGlow: false,
        child: Column(
          children: [
            const StatusArea(),
            const PageHeader(title: '设置'),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(16, 14, 16, 30 + bottomInset(context)),
                physics: const BouncingScrollPhysics(),
                children: [
                  _Group(
                    children: [
                      _SettingRow(
                        leading: SoulAvatar(
                          emoji: me.emoji,
                          ava: me.ava,
                          size: 38,
                        ),
                        label: me.name,
                        small: 'INFJ · 灵魂编号 88213047',
                        onTap: () => Navigator.of(context).push(
                          slideRoute(const EditProfileScreen()),
                        ),
                        showArrow: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _Group(
                    children: [
                      _SettingRow(
                        icon: '🔒',
                        label: '账号与安全',
                        trailingText: '已绑定手机',
                        showArrow: true,
                        onTap: () => showToast(
                          context,
                          '账号与安全：手机号已绑定、设备锁已开启',
                        ),
                      ),
                      _SettingRow(
                        icon: '🛡',
                        label: '隐私与权限',
                        trailingText: '标准',
                        showArrow: true,
                        onTap: () =>
                            showToast(context, '隐私设置：仅同频的人可以找到我'),
                      ),
                      _SettingRow(
                        icon: '💬',
                        label: '陌生人消息',
                        small: '关闭后仅好友可发起对话',
                        trailing: AppSwitch(
                          value: _strangerMessages,
                          onChanged: (v) {
                            setState(() => _strangerMessages = v);
                            _toggle('陌生人消息', v);
                          },
                        ),
                      ),
                      _SettingRow(
                        icon: '👁',
                        label: '展示在线状态',
                        small: '好友可以看到你最近活跃时间',
                        trailing: AppSwitch(
                          value: _showOnline,
                          onChanged: (v) {
                            setState(() => _showOnline = v);
                            _toggle('展示在线状态', v);
                          },
                        ),
                      ),
                      _SettingRow(
                        icon: '🕶',
                        label: '隐藏访问记录',
                        trailing: AppSwitch(
                          value: _hideVisits,
                          onChanged: (v) {
                            setState(() => _hideVisits = v);
                            _toggle('隐藏访问记录', v);
                          },
                        ),
                        divider: false,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _Group(
                    children: [
                      _SettingRow(
                        icon: '🔔',
                        label: '新消息通知',
                        trailing: AppSwitch(
                          value: _notifications,
                          onChanged: (v) {
                            setState(() => _notifications = v);
                            _toggle('新消息通知', v);
                          },
                        ),
                      ),
                      _SettingRow(
                        icon: '🌙',
                        label: '夜间免打扰',
                        trailingText: '23:00 – 08:00',
                        showArrow: true,
                        onTap: () => showToast(context, '夜间免打扰：23:00 – 08:00'),
                      ),
                      _SettingRow(
                        icon: '🎵',
                        label: '声音与震动',
                        trailingText: '星轨',
                        showArrow: true,
                        onTap: () => showToast(context, '提示音：星轨 · 可自定义'),
                        divider: false,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _Group(
                    children: [
                      _SettingRow(
                        icon: '🎨',
                        label: '深色模式',
                        trailingText: '跟随系统',
                        showArrow: true,
                        onTap: () => showToast(context, '外观：深色模式（跟随系统）'),
                      ),
                      _SettingRow(
                        icon: 'Aa',
                        label: '字体大小',
                        trailingText: '标准',
                        showArrow: true,
                        onTap: () => showToast(context, '字体大小：标准'),
                      ),
                      _SettingRow(
                        icon: '🗂',
                        label: '清除缓存',
                        trailingText: _cache,
                        showArrow: true,
                        onTap: () {
                          setState(() => _cache = '0 MB');
                          showToast(context, '已清理 12.4 MB 缓存');
                        },
                        divider: false,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _Group(
                    children: [
                      _SettingRow(
                        icon: '✦',
                        label: '关于星语',
                        trailingText: 'v0.9.1',
                        showArrow: true,
                        onTap: () =>
                            showToast(context, '星语 v0.9.1 · 让同频的人先遇见'),
                      ),
                      _SettingRow(
                        icon: '📄',
                        label: '用户协议与隐私政策',
                        showArrow: true,
                        onTap: () => showToast(context, '用户协议与隐私政策'),
                        divider: false,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => showAppSheet(
                      context,
                      title: '退出后仍会保留聊天记录',
                      actions: [
                        SheetAction(
                          label: '退出登录',
                          danger: true,
                          onTap: () => showToast(context, '已退出登录（演示）'),
                        ),
                      ],
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: C.pink.withValues(alpha: .1),
                        border: Border.all(
                          color: const Color(0xFFFF6E8C).withValues(alpha: .3),
                        ),
                      ),
                      child: const Text(
                        '退出登录',
                        style: TextStyle(fontSize: 13, color: Color(0xFFFF8FA9)),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 16, bottom: 4),
                    child: Text(
                      '星语 v0.9.1 · 让同频的人先遇见\n© 2026 Xingyu Studio',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 9.5,
                        height: 1.8,
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

class _Group extends StatelessWidget {
  const _Group({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: C.line),
        color: Colors.white.withValues(alpha: .03),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(children: children),
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    this.icon,
    this.leading,
    required this.label,
    this.small,
    this.trailingText,
    this.trailing,
    this.showArrow = false,
    this.onTap,
    this.divider = true,
  });

  final String? icon;
  final Widget? leading;
  final String label;
  final String? small;
  final String? trailingText;
  final Widget? trailing;
  final bool showArrow;
  final VoidCallback? onTap;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(
        border: divider
            ? const Border(top: BorderSide(color: Color(0x0FFFFFFF)))
            : null,
      ),
      child: Row(
        children: [
          leading ??
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: C.purple.withValues(alpha: .16),
                ),
                child: Text(
                  icon ?? '',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12.5, color: Color(0xFFEDE7FB)),
                ),
                if (small != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    small!,
                    style: const TextStyle(fontSize: 9.5, color: Color(0xFF8C82A8)),
                  ),
                ],
              ],
            ),
          ),
          if (trailingText != null)
            Text(
              trailingText!,
              style: const TextStyle(fontSize: 10.5, color: Color(0xFF8C82A8)),
            ),
          ?trailing,
          if (showArrow)
            const Padding(
              padding: EdgeInsets.only(left: 2),
              child: Text(
                '›',
                style: TextStyle(fontSize: 14, color: Color(0xFF6F6590)),
              ),
            ),
        ],
      ),
    );

    if (onTap == null) return content;
    return InkWell(onTap: onTap, child: content);
  }
}
