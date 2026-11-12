# AGENTS.md

## 项目

- **星语**（`package:xingyu`）的 Flutter 社交 App：当前以纯本地 mock 数据运行，暂无账号体系、真实网络请求或音视频能力；架构上允许并预留后端与网络接入，后续再替换 mock。
- 根目录的 `soul-prototype.html` 是视觉、文案和交互的唯一参考。修改 UI 文案、配色、模拟数据或行为时，以它为准。
- UI 文案和种子数据均为中文；新增用户可见文案时保持一致。
- `README.md` 记录了已实现页面与目录结构。

## 命令

在仓库根目录执行：

```bash
flutter pub get
flutter run -d macos     # 桌面预览（带手机外框）
flutter run -d chrome    # 浏览器预览
```

验证（完成前运行 analyze 和 test；涉及发布级改动时再执行构建）：

```bash
flutter analyze
flutter test
flutter build web --release
flutter build macos
```

- 单个测试文件：`flutter test test/widget_test.dart`
- 按名称运行单个测试：`flutter test --plain-name '星语首页可以正常渲染'`
- 没有代码生成、任务运行器、CI 或 pre-commit 配置。Lint 通过 `analysis_options.yaml` 启用 `flutter_lints`；`build/` 和各平台目录已被 analyzer 排除。

## 架构

- `lib/main.dart` 持有唯一的 `AppState` 并构建 `MaterialApp`。其 `builder` 会用 `PhoneFrame` 和 `AppScope` 包裹所有路由，因此页面可以假定二者一定存在。
- `lib/state.dart` 定义 `AppState extends ChangeNotifier`，在构造函数中从 `lib/data.dart` 初始化；所有修改状态的方法都必须调用 `notifyListeners()`。读取状态用 `AppScope.of(context)`（会触发重建）或 `AppScope.of(context, listen: false)`（用于回调）。
- `lib/screens/root_shell.dart` 是主框架：四个 Tab 放在 `IndexedStack` 中，由 `state.tabIndex` 切换。
- 数据模型在 `lib/models.dart`；所有模拟内容在 `lib/data.dart`；共享视觉常量在 `lib/theme.dart`；通用界面组件在 `lib/widgets/core.dart`。
- 当前 `AppState` 直接从 `data.dart` 初始化 mock 数据。后续接入后端时，网络请求与数据访问应集中在独立的数据层（如 repository / api client），不要把 HTTP 调用写进页面或 `AppState` 内部；页面通过状态层获取数据，以便用真实实现替换 mock。
- 网络与数据访问的基础设施在 `lib/services/`：`ApiClient` 封装 Dio（超时、Token、异常转换），`FeedRepository` 提供 mock / 远端两种实现，`Services` 是唯一入口。默认 `ApiConfig.useMock` 为 `true`；接后端时用 `--dart-define=USE_MOCK=false --dart-define=API_BASE_URL=...` 切换。新增接口时在 `lib/services/` 增加 repository，不要在页面或 `AppState` 里直接调 Dio。

## 约定与注意事项

- 允许引入后端、网络与数据存储相关的运行时依赖（如 `dio`、`http`、`shared_preferences`、`hive` 等），但应保持精简、按需添加，并优先选择维护活跃的包。当前阶段仍使用 `lib/data.dart` 的 mock 数据，真实网络与后端接入留待后续迭代。
- 星空、星球、图标和图片仍由 `CustomPainter`/渐变绘制，不新增图片资源。需要扩展视觉效果时请修改绘制逻辑。
- 使用 `theme.dart` 中的 `C.*` 颜色和渐变，避免硬编码颜色。头像 key 为 `a1`–`a5`；图片占位使用 `C.mediaGradient(index)`。
- 宽视口（≥500×720）会渲染拟真手机外框和状态栏，窄屏使用系统安全区。滚动/底部区域用 `bottomInset(context)` 留白；布局需要区分时用 `PhoneChrome.of(context)`，不要硬编码安全区 padding。
- 全屏页面使用 `Navigator.push(context, slideRoute(Page()))`，以保持原型的右滑转场。提示和操作面板使用 `widgets/core.dart` 的 `showToast` / `showAppSheet`，不要临时写对话框或 SnackBar。
- 唯一的测试是 `test/widget_test.dart`：它会等待 300 ms 让入场动画完成，并断言四个 Tab 文案和首页问候语。若这些文案变更，请同步更新测试。
