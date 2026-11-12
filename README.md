# 星语 · 灵魂社交 App

用 Flutter 完整实现的「星语」交互原型。深色星空视觉、星球首页、灵魂匹配、聊天养成、广场瞬间、好友与设置等页面均可交互，数据为本地模拟。

原型的唯一视觉与交互参考为根目录下的 `soul-prototype.html`。

## 运行

```bash
flutter pub get
flutter run -d macos     # 桌面预览（带 390 × 844 手机外框）
flutter run -d chrome    # 浏览器预览
flutter run              # iOS / Android 真机或模拟器
```

桌面 / 宽屏会显示手机外框和拟真状态栏；窄屏直接全屏并使用系统安全区。

默认使用本地 mock 数据（`lib/data.dart`），不会发起真实网络请求。接入后端时：

```bash
flutter run -d macos \
  --dart-define=USE_MOCK=false \
  --dart-define=API_BASE_URL=https://api.example.com
```

## 验证

```bash
flutter analyze
flutter test
flutter build web --release
flutter build macos
```

## 已实现功能

- **星球首页**：呼吸星球、旋转星轨、漂浮同频灵魂、在线人数与灵魂浓度、快捷入口。
- **灵魂匹配**：扫描计数动画 → 92% 契合度卡片 → 打招呼进入聊天 / 再匹配一次。
- **广场**：推荐 / 关注 / 附近切换、话题、关注、点赞回弹与 Toast、分享。
- **消息**：灵魂伴侣卡片、最近会话、群聊、未读角标、好友列表入口。
- **聊天室**：文字发送、拟真「正在输入」与随机回复、语音波形播放、图片消息、灵魂问答、心动值成长与「灵魂伴侣」点亮。
- **好友与申请**：搜索、按灵魂伴侣 / 密友 / 其他好友 / 群聊筛选、资料页、好友申请同意 / 忽略 / 打招呼。
- **瞬间**：九宫格、图片灯箱、点赞、关注、评论、我的瞬间。
- **我的**：个人资料卡、灵魂画像、常用入口、编辑资料（昵称 / 签名 / 头像 / 标签）、设置。
- **安全兜底**：举报原因、举报结果、拉黑结果、举报编号。
- **通用交互**：右滑页面路由、底部操作面板、定制 Toast、开关反馈。

## 目录结构

```
lib/
  main.dart                  应用入口、主题、手机外框挂载
  state.dart                 AppState + AppScope 全局状态
  data.dart                  模拟种子数据
  models.dart                数据模型
  theme.dart                 颜色 / 渐变 / 头像与图片配色
  services/
    api_config.dart          mock 开关与后端地址（--dart-define）
    api_client.dart          Dio 封装：超时 / Token / 日志 / 异常转换
    api_exception.dart       统一网络异常与中文提示
    feed_repository.dart     广场动态 repository（mock / 远端示例）
    services.dart            服务入口，按配置选择 mock 或远端实现
  screens/
    root_shell.dart          四 Tab 主框架
    planet_screen.dart       星球首页
    match_overlay.dart       灵魂匹配浮层
    plaza_screen.dart        广场
    messages_screen.dart     消息
    chat_screen.dart         聊天室
    me_screen.dart           我的
    moment_screen.dart       瞬间详情 + 灯箱
    profile_screen.dart      好友资料
    friends_screen.dart      好友列表
    requests_screen.dart     好友申请
    edit_profile_screen.dart 编辑资料
    settings_screen.dart     设置
    result_screen.dart       举报 / 拉黑结果
  widgets/
    core.dart                通用组件 / 手机外框 / Toast / 路由
    background.dart          星空与光晕背景
    bottom_nav.dart          底部导航
    planet_scene.dart        星球场景动画
```

## 说明

- 已引入 `dio` 作为网络层基础，默认走本地 mock、不发起真实请求；星空、光晕、星球、Tab 图标仍为 `CustomPainter` 自绘。
- 所有文案、配色、模拟数据与 `soul-prototype.html` 保持一致。
- 当前不含真实后端与账号体系；接入方式与示例代码见 `lib/services/`。
