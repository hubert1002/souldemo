import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'screens/root_shell.dart';
import 'state.dart';
import 'theme.dart';
import 'widgets/core.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const XingyuApp());
}

class XingyuApp extends StatefulWidget {
  const XingyuApp({super.key});

  @override
  State<XingyuApp> createState() => _XingyuAppState();
}

class _XingyuAppState extends State<XingyuApp> {
  final AppState _state = AppState();

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '星语',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: C.bg,
        colorScheme: const ColorScheme.dark(
          primary: C.lavender,
          secondary: C.pink,
          surface: C.bg,
          onSurface: C.text,
        ),
        splashColor: C.purple.withValues(alpha: .12),
        highlightColor: Colors.white.withValues(alpha: .04),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: C.lavender,
          selectionColor: C.purple.withValues(alpha: .32),
          selectionHandleColor: C.lavender,
        ),
      ),
      scrollBehavior: const _AppScrollBehavior(),
      builder: (context, child) {
        return AppScope(
          state: _state,
          child: PhoneFrame(
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
      home: const RootShell(),
    );
  }
}

/// 桌面端允许鼠标拖拽滚动，更接近手机预览手感。
class _AppScrollBehavior extends MaterialScrollBehavior {
  const _AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => const {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
        PointerDeviceKind.invertedStylus,
      };
}
