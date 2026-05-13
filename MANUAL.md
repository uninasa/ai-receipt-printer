# 操作手册 📖

完整的安装、配置和使用指南。

---

## 📥 安装

### Windows 用户

1. 下载最新版本的 `Release.zip`
2. 解压到任意目录
3. 双击运行 `ai_receipt_reader.exe`

> **注意**：首次运行可能需要安装 Visual C++ 运行库，Windows 会自动提示。

---

## ⚙️ 配置

### 1. 配置 DeepSeek API Key

首次使用需要配置 API Key：

1. 点击右上角 **设置** 图标（齿轮图标）
2. 访问 [DeepSeek 开放平台](https://platform.deepseek.com)
3. 注册/登录后，在"API Keys"页面创建新的 API Key
4. 复制 API Key，粘贴到应用的设置页面
5. 点击 **保存** 按钮

> **提示**：DeepSeek 提供免费额度，足够日常使用。API Key 会安全地存储在本地，不会上传到任何服务器。

### 2. 设置根目录

默认根目录为：`C:\Users\Administrator\.claude\projects`

如需更改：
1. 点击顶部工具栏的 **选择** 按钮
2. 选择你的 Claude Code 项目根目录
3. 应用会自动加载该目录下的所有子目录

---

## 🎯 使用流程

### 步骤 1：选择项目目录

在左侧栏（蓝色区域）查看所有项目目录：
- 点击任意项目文件夹
- 中间栏会显示该项目下的所有 JSONL 文件

### 步骤 2：选择对话文件

在中间栏（绿色区域）查看 JSONL 文件列表：
- 点击任意 `.jsonl` 文件
- 应用会自动解析文件内容
- 右侧栏会显示提取出的用户消息

### 步骤 3：选择问答对

在右侧栏（橙色区域）查看用户消息列表：
- 勾选需要分析的消息（支持多选）
- 点击消息右侧的 **ℹ️** 图标可查看完整内容
- 选择完成后，点击右上角的 **确认分析** 按钮

### 步骤 4：生成报告

进入问答分析页面：
1. 查看所有选中的问答对
2. 可以再次勾选/取消勾选
3. 点击右上角的 **究极 Agent 赋能** 按钮
4. 等待 AI 生成报告（通常 10-30 秒）
5. 在弹窗中查看生成的 Markdown 报告
6. 复制报告内容，粘贴到你需要的地方

---

## 💡 使用技巧

### 如何选择高质量的问答对？

- ✅ 选择解决了实际问题的对话
- ✅ 选择包含完整思考过程的对话
- ✅ 选择有技术深度的对话
- ❌ 避免选择简单的"试错"对话
- ❌ 避免选择重复的问题

### 如何提高报告质量？

1. **精选问答对**：质量 > 数量，选择 3-5 个高质量问答即可
2. **分类整理**：可以按主题分批生成多份报告
3. **补充说明**：生成后可以手动添加背景信息和总结

### 批量处理技巧

如果有多个项目需要分析：
1. 先在左侧栏切换到第一个项目
2. 选择文件并生成报告
3. 返回主页，切换到下一个项目
4. 重复操作

---

## 🔧 高级功能

### 查看完整对话链

应用会自动追踪完整的对话链条：
- 用户问题
- AI 的思考过程（thinking）
- AI 的工具调用
- AI 的最终回答

所有这些内容都会被提取并传递给 DeepSeek，生成更完整的分析报告。

### 自定义根目录

如果你的 Claude Code 项目不在默认位置：
1. 点击顶部的 **选择** 按钮
2. 浏览到你的项目根目录
3. 应用会记住这个设置

---

## ❓ 常见问题

### Q: 为什么需要配置 API Key？

**A**: 本应用使用 DeepSeek API 生成分析报告。使用你自己的 API Key 可以：
- 确保 API Key 的安全性
- 独立控制使用额度
- 避免共享 API 的限流问题

### Q: API Key 会被上传吗？

**A**: 不会。API Key 通过 SharedPreferences 存储在本地系统中，只在调用 DeepSeek API 时使用，不会上传到任何其他服务器。

### Q: 支持哪些对话格式？

**A**: 目前支持 Claude Code 的标准 JSONL 格式，每行一个 JSON 对象，包含：
- `message`: 消息内容
- `uuid`: 消息唯一标识
- `parentUuid`: 父消息标识（用于追踪对话链）
- `role`: 角色（user/assistant）

### Q: 生成报告需要多长时间？

**A**: 通常 10-30 秒，取决于：
- 选择的问答对数量
- 问答内容的长度
- 网络状况

### Q: 可以离线使用吗？

**A**: 部分功能可以：
- ✅ 文件浏览和解析：完全离线
- ✅ 问答对选择：完全离线
- ❌ 生成 AI 报告：需要联网调用 DeepSeek API

### Q: DeepSeek API 收费吗？

**A**: DeepSeek 提供免费额度，对于日常使用完全足够。具体价格请查看 [DeepSeek 定价页面](https://platform.deepseek.com/pricing)。

### Q: 报告生成失败怎么办？

**A**: 可能的原因和解决方案：
1. **API Key 未配置**：检查设置页面是否已保存 API Key
2. **API Key 无效**：重新生成并配置新的 API Key
3. **网络问题**：检查网络连接，或稍后重试
4. **额度不足**：检查 DeepSeek 账户余额

### Q: 可以导出报告吗？

**A**: 当前版本在弹窗中显示报告，你可以：
- 全选复制（Ctrl+A, Ctrl+C）
- 粘贴到 Markdown 编辑器
- 保存为 `.md` 文件

未来版本会添加一键导出功能。

---

## 🛠️ 开发者指南

### 环境要求

- Flutter SDK 3.0+
- Visual Studio 2019/2022（含 C++ 桌面开发工具）
- Windows 10/11

### 克隆项目

```bash
git clone https://github.com/your-repo/ai-receipt-reader.git
cd ai-receipt-reader
```

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

### 项目结构

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

### 技术栈

- **前端框架**：Flutter 3.x
- **语言**：Dart
- **HTTP 请求**：http package
- **本地存储**：shared_preferences
- **文件选择**：file_picker
- **AI 服务**：DeepSeek API（兼容 OpenAI 格式）

---

## 🤝 反馈与支持

遇到问题或有建议？

- 提交 Issue：[GitHub Issues](https://github.com/your-repo/ai-receipt-reader/issues)
- 发起讨论：[GitHub Discussions](https://github.com/your-repo/ai-receipt-reader/discussions)

---

**祝你使用愉快！让 AI 帮你写 AI 效能报告！** 🎉
