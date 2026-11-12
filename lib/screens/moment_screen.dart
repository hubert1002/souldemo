import 'package:flutter/material.dart';

import '../models.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/background.dart';
import '../widgets/core.dart';

/// 瞬间详情页：作者 / 九宫格 / 放大查看 / 点赞 / 关注 / 评论。
class MomentScreen extends StatefulWidget {
  const MomentScreen({super.key, required this.friendId});

  final String friendId;

  @override
  State<MomentScreen> createState() => _MomentScreenState();
}

class _MomentScreenState extends State<MomentScreen> {
  late final Moment? _moment;
  late final List<MomentComment> _comments;
  final TextEditingController _input = TextEditingController();
  final FocusNode _focus = FocusNode();

  bool _liked = false;
  bool _following = false;
  int _likes = 0;
  int? _lightboxIndex;

  @override
  void initState() {
    super.initState();
    _moment = AppScope.of(context, listen: false).buildMoment(widget.friendId);
    _comments = [
      ...?_moment?.comments,
    ];
    _likes = _moment?.likes ?? 0;
  }

  @override
  void dispose() {
    _input.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _toggleLike() {
    setState(() {
      _liked = !_liked;
      _likes += _liked ? 1 : -1;
    });
    if (_liked) {
      showToast(context, '已共鸣 · 你的喜欢会出现在 TA 的瞬间里');
    }
  }

  void _toggleFollow() {
    setState(() => _following = !_following);
    showToast(
      context,
      _following ? '关注成功，TA 的新瞬间会优先给你' : '已取消关注',
    );
  }

  void _sendComment() {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    final me = AppScope.of(context, listen: false).me;
    setState(() {
      _comments.add(
        MomentComment(
          name: me.name,
          emoji: me.emoji,
          ava: me.ava,
          text: text,
        ),
      );
      _input.clear();
    });
    showToast(context, '评论已发布 ✦');
  }

  @override
  Widget build(BuildContext context) {
    final moment = _moment;

    if (moment == null) {
      return Scaffold(
        backgroundColor: C.bg,
        body: const Center(
          child: Text('瞬间不存在', style: TextStyle(color: C.muted)),
        ),
      );
    }

    final subtitle = moment.isMe ? '我的瞬间' : '${moment.name}的瞬间';

    return Scaffold(
      backgroundColor: C.bg,
      resizeToAvoidBottomInset: true,
      body: AppBackdrop(
        pinkGlow: false,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Column(
              children: [
                const StatusArea(),
                PageHeader(title: '瞬间', subtitle: subtitle),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 22),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _AuthorRow(
                        moment: moment,
                        following: _following,
                        onFollow: _toggleFollow,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        moment.text,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.8,
                          color: Color(0xFFE7E1F8),
                        ),
                      ),
                      const SizedBox(height: 13),
                      _MomentGrid(
                        cells: moment.grid,
                        onTap: (i) => setState(() => _lightboxIndex = i),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 15),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Color(0x12FFFFFF)),
                            bottom: BorderSide(color: Color(0x12FFFFFF)),
                          ),
                        ),
                        child: Row(
                          children: [
                            _StatAction(
                              icon: _liked
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              label: '$_likes',
                              color: _liked
                                  ? const Color(0xFFFF6FA0)
                                  : const Color(0xFF9E94BC),
                              onTap: _toggleLike,
                            ),
                            const SizedBox(width: 18),
                            _StatAction(
                              icon: Icons.chat_bubble_outline_rounded,
                              label: '${_comments.length}',
                              onTap: () => _focus.requestFocus(),
                            ),
                            const Spacer(),
                            _StatAction(
                              icon: Icons.auto_awesome,
                              label: '分享',
                              onTap: () => showToast(context, '瞬间链接已复制'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        '共鸣与评论',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: C.muted,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_comments.isEmpty)
                        const Text(
                          '还没有评论，来做第一个同频的人',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF7E7499),
                          ),
                        )
                      else
                        for (final comment in _comments)
                          _CommentRow(comment: comment),
                    ],
                  ),
                ),
                _CommentBar(
                  controller: _input,
                  focusNode: _focus,
                  onSend: _sendComment,
                ),
              ],
            ),
            if (_lightboxIndex != null)
              _Lightbox(
                moment: moment,
                index: _lightboxIndex!,
                onClose: () => setState(() => _lightboxIndex = null),
              ),
          ],
        ),
      ),
    );
  }
}

class _AuthorRow extends StatelessWidget {
  const _AuthorRow({
    required this.moment,
    required this.following,
    required this.onFollow,
  });

  final Moment moment;
  final bool following;
  final VoidCallback onFollow;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SoulAvatar(emoji: moment.emoji, ava: moment.ava, size: 42),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                moment.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: C.text,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                moment.meta,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF8C82A8),
                ),
              ),
            ],
          ),
        ),
        if (!moment.isMe)
          GestureDetector(
            onTap: onFollow,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(99),
                color: following
                    ? Colors.transparent
                    : C.purple.withValues(alpha: .12),
                border: Border.all(
                  color: following
                      ? C.line
                      : const Color(0xFFB48CFF).withValues(alpha: .45),
                ),
              ),
              child: Text(
                following ? '已关注' : '关注',
                style: TextStyle(
                  fontSize: 11,
                  color: following ? C.muted : C.lavender,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _MomentGrid extends StatelessWidget {
  const _MomentGrid({required this.cells, required this.onTap});

  final List<String> cells;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 7,
        mainAxisSpacing: 7,
      ),
      itemCount: cells.length,
      itemBuilder: (context, i) {
        return GestureDetector(
          onTap: () => onTap(i),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: C.mediaGradient(i),
              border: Border.all(color: Colors.white.withValues(alpha: .07)),
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    cells[i],
                    style: const TextStyle(fontSize: 26, height: 1),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            const Color(0xFF06030E).withValues(alpha: .35),
                          ],
                          stops: const [0, 1],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatAction extends StatelessWidget {
  const _StatAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = const Color(0xFF9E94BC),
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(fontSize: 11.5, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentRow extends StatelessWidget {
  const _CommentRow({required this.comment});

  final MomentComment comment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SoulAvatar(emoji: comment.emoji, ava: comment.ava, size: 30),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.name,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFD9D0F5),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  comment.text,
                  style: const TextStyle(
                    fontSize: 11.5,
                    height: 1.6,
                    color: Color(0xFFC0B6DC),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentBar extends StatelessWidget {
  const _CommentBar({
    required this.controller,
    required this.focusNode,
    required this.onSend,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(14, 9, 14, 9 + bottomInset(context)),
      decoration: BoxDecoration(
        color: const Color(0xF20A0612),
        border: const Border(top: BorderSide(color: Color(0x0FFFFFFF))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: Colors.white.withValues(alpha: .09)),
                color: Colors.white.withValues(alpha: .06),
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                maxLength: 60,
                onSubmitted: (_) => onSend(),
                textInputAction: TextInputAction.send,
                style: const TextStyle(fontSize: 12, color: Colors.white),
                cursorColor: C.lavender,
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  counterText: '',
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  hintText: '说点什么…',
                  hintStyle:
                      TextStyle(fontSize: 12, color: Color(0xFF7E7499)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              final enabled = value.text.trim().isNotEmpty;
              return GestureDetector(
                onTap: enabled ? onSend : null,
                child: Opacity(
                  opacity: enabled ? 1 : .4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(99),
                      gradient: C.gradHorizontal,
                    ),
                    child: const Text(
                      '发送',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Lightbox extends StatelessWidget {
  const _Lightbox({
    required this.moment,
    required this.index,
    required this.onClose,
  });

  final Moment moment;
  final int index;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final caption =
        '${moment.isMe ? '我的瞬间' : '${moment.name}的瞬间'} · '
        '${index + 1} / ${moment.grid.length}';

    return Positioned.fill(
      child: Material(
        color: const Color(0xF704020C),
        child: GestureDetector(
          onTap: onClose,
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: [
              Center(
                child: GestureDetector(
                  onTap: () {},
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 300,
                        height: 300,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: C.mediaGradient(index),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: .12),
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x99000000),
                              blurRadius: 70,
                              offset: Offset(0, 30),
                            ),
                          ],
                        ),
                        child: Text(
                          moment.grid[index],
                          style: const TextStyle(fontSize: 88, height: 1),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        caption,
                        style: const TextStyle(
                          fontSize: 11,
                          letterSpacing: .1,
                          color: C.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 54,
                right: 18,
                child: GestureDetector(
                  onTap: onClose,
                  child: Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: .07),
                      border: Border.all(color: C.line),
                    ),
                    child: const Text(
                      '✕',
                      style: TextStyle(fontSize: 13, color: Color(0xFFCFC5EA)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
