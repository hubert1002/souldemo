import 'package:flutter/material.dart';

import '../state.dart';
import '../theme.dart';
import '../widgets/background.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/core.dart';
import 'me_screen.dart';
import 'messages_screen.dart';
import 'planet_screen.dart';
import 'plaza_screen.dart';

/// 主框架：状态栏 + 四个 Tab 页 + 悬浮底部导航。
class RootShell extends StatelessWidget {
  const RootShell({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);

    return Scaffold(
      backgroundColor: C.bg,
      body: AppBackdrop(
        child: Column(
          children: [
            const StatusArea(),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: IndexedStack(
                      index: state.tabIndex,
                      children: const [
                        PlanetScreen(),
                        PlazaScreen(),
                        MessagesScreen(),
                        MeScreen(),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: BottomNav(
                      index: state.tabIndex,
                      showMessageDot: state.messagesDot,
                      onTap: state.setTab,
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
