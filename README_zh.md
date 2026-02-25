# claude-cobrain

[English](./README.md) | **简体中文**

> ⚠️ **预览阶段**：功能可能不稳定，并可能包含破坏性变更。

claude-cobrain 是一个 Claude Code 插件。它通过持续分析屏幕活动，为 Claude 构建你工作流的持久记忆。

**北极星指标：**

- 周/月度工作总结具备 **95%+ 准确率**
- 提供具**可衡量经济价值**的建设性建议

[目标与理念](https://claude-cobrain-web.vercel.app/)

## 隐私

- **仅限本地**：仅依赖本地后端（如 `ollama` / `fastvlm`）处理截图。
- **本地存储**：数据仅存至 `~/.claude/cobrain`（可通过 `OUTPUT_DIR` 更改）。
- **完全受控**：执行 `/claude-cobrain:cobrain stop` 或 `uninstall` 随时关停/卸载。

## 快速开始

> 当前仅支持 macOS。

**安装**

1. 添加市场依赖：
```shell
/plugin marketplace add cyrus-cai/claude-cobrain
```

2. 安装插件：
```shell
/plugin install claude-cobrain
```

3. 部署守护进程：
```shell
/claude-cobrain:cobrain install
```


然后，守护进程会自动启动，并在 `~/.claude/cobrain/` 中生成 markdown 文件。
> Example:
> ![example-raw](./example-raw.png)



**配置要求**

| 组件       | 要求               | 用途                       |
| ---------- | ------------------ | -------------------------- |
| 操作系统   | macOS              | LaunchAgent、Accessibility |
| Python     | 3.11               | 守护进程运行环境           |
| Ollama     | 最新版本           | 本地 LLM 推理              |
| 模型       | qwen3-vl:2b        | 本地 VLM 推理（20亿参数）  |
| Python 包  | Pillow, ollama     | 图像处理与 API 请求        |
| 磁盘空间   | ~2GB               | 存放模型与本地日志         |
| macOS 权限 | 辅助功能、屏幕录制 | 获取活动窗口并截图         |

## 核心工作流

- 截取顶层活动窗口
- 交由本地 VLM 分析
- 摘要附加时间戳并追加至 Markdown

## 许可

基于 MIT 许可证发布，详见 [LICENSE](LICENSE)。
