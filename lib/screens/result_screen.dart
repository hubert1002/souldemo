import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/background.dart';
import '../widgets/core.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({
    super.key,
    required this.kind,
    required this.friendName,
    this.reason,
    this.popProfileOnDone = true,
  });

  final String kind; // report / block
  final String friendName;
  final String? reason;
  final bool popProfileOnDone;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late String _kind = widget.kind;

  bool get _isBlock => _kind == 'block';

  void _done() {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final wasBlock = _isBlock;
    navigator.pop();
    if (widget.popProfileOnDone) {
      navigator.pop();
    }
    showToastOn(
      messenger,
      wasBlock ? '已拉黑，TA 不会再打扰你' : '举报已提交，感谢你让星语更安全',
    );
  }

  void _secondAction() {
    if (!_isBlock) {
      setState(() => _kind = 'block');
      showToast(context, '已拉黑「${widget.friendName}」');
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    navigator.pop();
    if (widget.popProfileOnDone) {
      navigator.pop();
    }
    showToastOn(messenger, '已解除拉黑（演示）');
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.friendName;
    final reason = widget.reason ?? '骚扰或不当内容';

    final icon = _isBlock ? '🚫' : '🛡';
    final title = _isBlock ? '已拉黑「$name」' : '举报已提交';
    final desc = _isBlock
        ? '你不再会收到 TA 的消息与互动提醒，TA 也无法查看你的瞬间和主页。'
        : '我们已收到你对「$name」的举报。星语会在 24 小时内完成审核，处理结果会通过站内消息告知你。';
    final note = _isBlock
        ? '拉黑可以撤销，之后可在「设置 · 隐私与权限」中管理黑名单。'
        : '请如实填写举报内容。恶意举报会导致账号功能受限。';
    final second = _isBlock ? '解除拉黑' : '同时拉黑 TA';

    final rows = _isBlock
        ? const [
            ('关系', '已拉黑'),
            ('消息', '不再接收'),
            ('主页', '互不可见'),
          ]
        : [
            ('处理状态', '已进入审核'),
            ('举报原因', reason),
            ('预计反馈', '24 小时内'),
            (
              '举报编号',
              'XY${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
            ),
          ];

    return Scaffold(
      backgroundColor: C.bg,
      body: AppBackdrop(
        pinkGlow: false,
        child: Column(
          children: [
            const StatusArea(),
            PageHeader(title: _isBlock ? '拉黑结果' : '举报结果'),
            Expanded(
              child: ListView(
                padding:
                    EdgeInsets.fromLTRB(18, 26, 18, 24 + bottomInset(context)),
                physics: const BouncingScrollPhysics(),
                children: [
                  Center(
                    child: Container(
                      width: 86,
                      height: 86,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            C.purple.withValues(alpha: .4),
                            C.pink.withValues(alpha: .2),
                          ],
                        ),
                        border: Border.all(
                          color: const Color(0xFFB48CFF)
                              .withValues(alpha: .35),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: C.purple.withValues(alpha: .45),
                            blurRadius: 46,
                            offset: const Offset(0, 18),
                            spreadRadius: -18,
                          ),
                        ],
                      ),
                      child: Text(icon, style: const TextStyle(fontSize: 36)),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: C.text,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 286),
                      child: Text(
                        desc,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 11.5,
                          height: 1.75,
                          color: Color(0xFFA99FC4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: C.line),
                      color: Colors.white.withValues(alpha: .03),
                    ),
                    child: Column(
                      children: [
                        for (var i = 0; i < rows.length; i++)
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            decoration: BoxDecoration(
                              border: i == 0
                                  ? null
                                  : const Border(
                                      top: BorderSide(
                                        color: Color(0x0FFFFFFF),
                                      ),
                                    ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  rows[i].$1,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: C.muted,
                                  ),
                                ),
                                const Spacer(),
                                Flexible(
                                  child: Text(
                                    rows[i].$2,
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFEDE7FB),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  GradientButton(
                    label: '完成',
                    height: 46,
                    onTap: _done,
                  ),
                  const SizedBox(height: 9),
                  GhostButton(
                    label: second,
                    height: 43,
                    onTap: _secondAction,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 270),
                      child: Text(
                        note,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 9.5,
                          height: 1.7,
                          color: Color(0xFF5E5478),
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
    );
  }
}
