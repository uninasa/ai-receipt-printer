# AI 效能数据分析工具

一个基于 Flutter 开发的 Windows 桌面应用，用于读取和分析 AI 对话记录（JSONL 格式），并通过 DeepSeek API 生成专业的效能分析报告。

## 功能特性

- 📁 **多项目管理**：支持浏览多个项目目录，快速切换
- 📄 **JSONL 解析**：自动解析 AI 对话记录，提取用户问题和 AI 回答
- ✅ **智能选择**：多选问答对，灵活组合分析内容
- 🤖 **AI 生成报告**：调用 DeepSeek API 生成结构化的 Markdown 分析报告
- 🔒 **本地存储**：API Key 安全存储在本地，无需担心泄露

## 快速开始

### 安装

1. 下载 `Release` 文件夹
2. 双击运行 `ai_receipt_reader.exe`

### 配置

首次使用需要配置 DeepSeek API Key：

1. 点击右上角 **设置** 图标
2. 访问 [DeepSeek 平台](https://platform.deepseek.com) 获取 API Key
3. 输入 API Key 并保存

### 使用流程

#### 1. 选择根目录

- 默认目录：`C:\Users\Administrator\.claude\projects`
- 点击 **选择** 按钮可更换根目录

#### 2. 浏览项目

- **左侧栏**：显示根目录下的所有项目文件夹
- 点击项目文件夹，加载该项目的 JSONL 文件

#### 3. 选择对话文件

- **中间栏**：显示选中项目下的所有 `.jsonl` 文件
- 点击文件，自动解析用户消息

#### 4. 选择问答对

- **右侧栏**：显示解析出的用户消息列表
- 勾选需要分析的消息
- 点击 **确认分析** 按钮

#### 5. 生成报告

- 在问答分析页面，再次勾选需要的问答对
- 点击 **究极 Agent 赋能** 按钮
- 等待 AI 生成报告（通常 10-30 秒）
- 查看生成的 Markdown 格式报告

## 技术架构

- **前端框架**：Flutter 3.x
- **语言**：Dart
- **AI 服务**：DeepSeek API
- **本地存储**：SharedPreferences
- **平台**：Windows 桌面

## 项目结构

```
lib/
├── main.dart                    # 应用入口
├── models/
│   └── qa_pair.dart            # 问答对数据模型
├── screens/
│   ├── home_screen.dart        # 主界面（三栏布局）
│   ├── qa_analysis_screen.dart # 问答分析页面
│   └── settings_screen.dart    # 设置页面
└── services/
    └── llm_service.dart        # DeepSeek API 调用服务
```

## 开发指南

### 环境要求

- Flutter SDK 3.0+
- Visual Studio 2019/2022（含 C++ 桌面开发工具）
- Windows 10/11

### 安装依赖

```bash
flutter pub get
```

### 运行开发版本

```bash
flutter run -d windows
```

### 构建发布版本

```bash
flutter build windows --release
```

构建产物位于：`build\windows\runner\Release\`

## 常见问题

### Q: 为什么需要配置 API Key？

A: 本应用使用 DeepSeek API 生成分析报告，需要用户自己的 API Key。这样可以确保 API Key 的安全性和使用额度的独立性。

### Q: API Key 存储在哪里？

A: API Key 通过 SharedPreferences 存储在本地系统中，不会上传到任何服务器。

### Q: 支持哪些 AI 对话格式？

A: 目前支持标准的 JSONL 格式，每行一个 JSON 对象，包含 `message`、`uuid`、`parentUuid` 等字段。

### Q: 生成报告需要多长时间？

A: 通常 10-30 秒，取决于选择的问答对数量和网络状况。

### Q: 可以离线使用吗？

A: 文件浏览和解析功能可以离线使用，但生成 AI 报告需要联网调用 DeepSeek API。

## 许可证

MIT License

## 作者

开发于 2026 年

---

**提示**：首次使用建议先用少量问答对测试，确认 API Key 配置正确后再批量分析。
