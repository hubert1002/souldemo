import 'package:flutter/material.dart';

import '../data.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/background.dart';
import '../widgets/core.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _name;
  late final TextEditingController _sig;
  late final TextEditingController _tagInput;
  late String _emoji;
  late String _ava;
  late List<String> _tags;

  @override
  void initState() {
    super.initState();
    final me = AppScope.of(context, listen: false);
    _name = TextEditingController(text: me.me.name);
    _sig = TextEditingController(text: me.me.sig);
    _tagInput = TextEditingController();
    _emoji = me.me.emoji;
    _ava = me.me.ava;
    _tags = List<String>.from(me.me.tags);
  }

  @override
  void dispose() {
    _name.dispose();
    _sig.dispose();
    _tagInput.dispose();
    super.dispose();
  }

  void _setAvatar(Map<String, String> avatar) {
    setState(() {
      _emoji = avatar['emoji']!;
      _ava = avatar['ava']!;
    });
    showToast(context, '头像已更换');
  }

  void _addTag(String raw) {
    final tag = raw.trim();
    if (tag.isEmpty) return;
    if (_tags.length >= 5) {
      showToast(context, '最多 5 个人格标签');
      return;
    }
    if (_tags.contains(tag)) {
      showToast(context, '这个标签已经有了');
      return;
    }
    setState(() => _tags.add(tag));
    _tagInput.clear();
  }

  void _save() {
    final name = _name.text.trim();
    if (name.isEmpty) {
      showToast(context, '昵称不能为空');
      return;
    }
    final sig = _sig.text.trim().isEmpty
        ? '还没有写签名，留一点空白也很好。'
        : _sig.text.trim();
    AppScope.of(context, listen: false).saveProfile(
      name: name,
      sig: sig,
      emoji: _emoji,
      ava: _ava,
      tags: _tags,
    );
    showToast(context, '资料已更新 ✦');
    Navigator.of(context).pop();
  }

  void _chooseAvatar() {
    showAppSheet(
      context,
      title: '选择头像',
      actions: [
        for (final a in avatarChoices)
          SheetAction(
            label: '${a['emoji']}　'
                '${a['emoji'] == _emoji ? '当前头像' : '使用这个头像'}',
            onTap: () => _setAvatar(a),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      body: AppBackdrop(
        pinkGlow: false,
        child: Column(
          children: [
            const StatusArea(),
            PageHeader(
              title: '编辑资料',
              trailing: GestureDetector(
                onTap: _save,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                  child: Text(
                    '保存',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFC9A8FF),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(16, 14, 16, 30 + bottomInset(context)),
                physics: const BouncingScrollPhysics(),
                children: [
                  Column(
                    children: [
                      GestureDetector(
                        onTap: _chooseAvatar,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            SoulAvatar(emoji: _emoji, ava: _ava, size: 88),
                            Positioned(
                              right: -2,
                              bottom: -2,
                              child: Container(
                                width: 28,
                                height: 28,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: C.gradHorizontal,
                                  border: Border.all(color: C.bg, width: 2),
                                ),
                                child: const Text(
                                  '📷',
                                  style: TextStyle(fontSize: 11),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Text(
                          '头像会出现在你的瞬间与匹配卡片里',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            height: 1.6,
                            color: Color(0xFF8C82A8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (final a in avatarChoices)
                            Padding(
                              padding: const EdgeInsets.only(right: 9),
                              child: GestureDetector(
                                onTap: () => _setAvatar(a),
                                child: Container(
                                  width: 38,
                                  height: 38,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: a['emoji'] == _emoji
                                        ? C.pink.withValues(alpha: .18)
                                        : Colors.white.withValues(alpha: .05),
                                    border: Border.all(
                                      color: a['emoji'] == _emoji
                                          ? const Color(0xFFFF8FB1)
                                          : C.line,
                                    ),
                                    boxShadow: a['emoji'] == _emoji
                                        ? [
                                            BoxShadow(
                                              color: C.pink
                                                  .withValues(alpha: .14),
                                              spreadRadius: 3,
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Text(
                                    a['emoji']!,
                                    style: const TextStyle(fontSize: 17),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _FormCard(
                    label: '昵称',
                    small: '最多 12 字',
                    child: Column(
                      children: [
                        _InputBox(
                          child: TextField(
                            controller: _name,
                            maxLength: 12,
                            onChanged: (_) => setState(() {}),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                            ),
                            cursorColor: C.lavender,
                            decoration: const InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              counterText: '',
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 11,
                              ),
                              hintText: '给自己一个名字',
                              hintStyle: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF7E7499),
                              ),
                            ),
                          ),
                        ),
                        _NoteRow(
                          left: '其他同频者可以通过昵称找到你',
                          right: '${_name.text.length}/12',
                        ),
                      ],
                    ),
                  ),
                  _FormCard(
                    label: '个性签名',
                    small: '让别人先听见你的频率',
                    child: Column(
                      children: [
                        _InputBox(
                          child: TextField(
                            controller: _sig,
                            maxLength: 40,
                            maxLines: 3,
                            onChanged: (_) => setState(() {}),
                            style: const TextStyle(
                              fontSize: 13,
                              height: 1.65,
                              color: Colors.white,
                            ),
                            cursorColor: C.lavender,
                            decoration: const InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              counterText: '',
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 11,
                              ),
                              hintText: '写一句最近的心情…',
                              hintStyle: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF7E7499),
                              ),
                            ),
                          ),
                        ),
                        _NoteRow(
                          left: '建议 1–2 句，会展示在资料页',
                          right: '${_sig.text.length}/40',
                        ),
                      ],
                    ),
                  ),
                  _FormCard(
                    label: '人格标签',
                    small: '最多 5 个',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: _tags.isEmpty
                              ? const [
                                  Text(
                                    '还没有标签，从下方选一个吧',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFF6F6590),
                                    ),
                                  ),
                                ]
                              : [
                                  for (final tag in _tags)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 9,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(99),
                                        color: C.purple.withValues(alpha: .18),
                                        border: Border.all(
                                          color: const Color(0xFFB48CFF)
                                              .withValues(alpha: .35),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            tag,
                                            style: const TextStyle(
                                              fontSize: 10.5,
                                              color: C.lavenderSoft,
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          GestureDetector(
                                            onTap: () => setState(
                                              () => _tags.remove(tag),
                                            ),
                                            child: const Text(
                                              '✕',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Color(0xFFFF9CC0),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                        ),
                        const SizedBox(height: 10),
                        _InputBox(
                          child: TextField(
                            controller: _tagInput,
                            maxLength: 6,
                            onSubmitted: _addTag,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                            ),
                            cursorColor: C.lavender,
                            textInputAction: TextInputAction.done,
                            decoration: const InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              counterText: '',
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 11,
                              ),
                              hintText: '输入标签后回车添加',
                              hintStyle: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF7E7499),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          padding: const EdgeInsets.only(top: 10),
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Color(0x14FFFFFF)),
                            ),
                          ),
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              const SizedBox(
                                width: double.infinity,
                                child: Text(
                                  '推荐标签',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    color: Color(0xFF7E7499),
                                  ),
                                ),
                              ),
                              for (final tag in suggestTags
                                  .where((t) => !_tags.contains(t))
                                  .take(6))
                                GestureDetector(
                                  onTap: () => _addTag(tag),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 9,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(99),
                                      border: Border.all(
                                        color: const Color(0xFFB48CFF)
                                            .withValues(alpha: .3),
                                      ),
                                    ),
                                    child: Text(
                                      '+ $tag',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Color(0xFFA99FC4),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: C.line),
                      color: Colors.white.withValues(alpha: .03),
                    ),
                    child: const Column(
                      children: [
                        _InfoRow(label: '城市', value: '上海'),
                        _InfoRow(label: '生日', value: '11 月 07 日'),
                        _InfoRow(label: '灵魂编号', value: '88213047', last: true),
                      ],
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

class _FormCard extends StatelessWidget {
  const _FormCard({
    required this.label,
    required this.child,
    this.small,
  });

  final String label;
  final String? small;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: C.line),
        color: Colors.white.withValues(alpha: .03),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: C.muted),
              ),
              if (small != null) ...[
                const SizedBox(width: 6),
                Text(
                  small!,
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6F6590),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 9),
          child,
        ],
      ),
    );
  }
}

class _InputBox extends StatelessWidget {
  const _InputBox({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: Colors.white.withValues(alpha: .08)),
        color: Colors.white.withValues(alpha: .05),
      ),
      child: child,
    );
  }
}

class _NoteRow extends StatelessWidget {
  const _NoteRow({required this.left, required this.right});

  final String left;
  final String right;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(
              left,
              style: const TextStyle(fontSize: 9.5, color: Color(0xFF6F6590)),
            ),
          ),
          Text(
            right,
            style: const TextStyle(fontSize: 9.5, color: Color(0xFF6F6590)),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.last = false,
  });

  final String label;
  final String value;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: last ? 12 : 9),
      decoration: BoxDecoration(
        border: last
            ? null
            : const Border(bottom: BorderSide(color: Color(0x0DFFFFFF))),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12.5, color: C.text),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 11.5, color: Color(0xFF8C82A8)),
          ),
        ],
      ),
    );
  }
}
