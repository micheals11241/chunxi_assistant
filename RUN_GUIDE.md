# 春禧助手 - 运行指南

## 项目简介
「春禧助手」是一个喜庆的春节助手 App，包含三个功能：
- **礼簿**：记录人情账，红包往来
- **锦囊**：拜年吉祥话 + 应对尴尬提问
- **亲戚**：亲戚关系计算器

---

## 快速运行（如果已安装 Flutter）

```bash
# 1. 进入项目目录
cd A:/demo/chunxi_assistant

# 2. 安装依赖
flutter pub get

# 3. 运行在 Chrome 浏览器
flutter run -d chrome

# 或者运行在 Web 服务器模式
flutter run -d web-server --web-port=8080
```

---

## 安装 Flutter（如果没有安装）

### 方法一：手动下载（推荐）

1. **下载 Flutter SDK**
   - 访问：https://docs.flutter.dev/get-started/install/windows
   - 或直接下载：https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.24.5-stable.zip

2. **解压到合适位置**
   ```
   例如解压到：C:\flutter
   ```

3. **配置环境变量**
   - 打开「系统属性」→「高级」→「环境变量」
   - 在 Path 中添加：`C:\flutter\bin`
   - 或在 PowerShell 中运行：
     ```powershell
     [Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\flutter\bin", "User")
     ```

4. **验证安装**
   ```bash
   flutter --version
   flutter doctor
   ```

### 方法二：使用 Chocolatey

```powershell
choco install flutter
```

### 方法三：使用 Scoop

```powershell
scoop install flutter
```

---

## 运行项目

### Web 端运行（最简单）

```bash
# 进入项目目录
cd A:/demo/chunxi_assistant

# 安装依赖
flutter pub get

# 启用 Web 支持（首次需要）
flutter config --enable-web

# 运行在 Chrome
flutter run -d chrome

# 或者构建 Web 版本
flutter build web
```

构建完成后，`build/web` 目录可以直接部署到任何静态服务器。

### Android 模拟器运行

```bash
# 1. 打开 Android Studio，启动模拟器
# 2. 运行项目
flutter run
```

---

## 项目结构

```
chunxi_assistant/
├── lib/
│   ├── main.dart              # 入口文件
│   ├── theme/
│   │   └── app_theme.dart     # 喜庆主题样式
│   ├── screens/
│   │   ├── home_screen.dart   # 主页（底部导航）
│   │   ├── gift_book_screen.dart  # 礼簿页面
│   │   ├── tips_screen.dart   # 锦囊页面
│   │   └── relative_screen.dart   # 亲戚计算页面
│   ├── models/
│   │   ├── gift_record.dart   # 礼金记录模型
│   │   └── relative_relation.dart
│   ├── widgets/
│   │   └── gift_card.dart     # 礼金卡片组件
│   ├── services/
│   │   └── storage_service.dart   # 本地存储服务
│   └── utils/
│       ├── greetings_data.dart    # 吉祥话数据
│       └── relation_calculator.dart   # 关系计算逻辑
├── web/                       # Web 平台配置
├── android/                   # Android 平台配置
├── ios/                       # iOS 平台配置
└── pubspec.yaml              # 依赖配置
```

---

## 常见问题

### 1. flutter命令找不到
确保 Flutter 的 `bin` 目录已添加到系统 PATH 中。

### 2. Web 编译失败
```bash
flutter config --enable-web
flutter upgrade
```

### 3. 依赖安装失败
```bash
flutter clean
flutter pub get
```

---

## 技术栈
- Flutter 3.24+
- Dart 3.0+
- shared_preferences（本地存储）
- Material Design 3

---

祝您春节快乐！🧧
