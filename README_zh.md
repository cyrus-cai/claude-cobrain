# claude-cobrain

[English](README.md) | **简体中文**

> ⚠️ **Note**: This project is currently in the **preview stage**. Features may be unstable, and there might be breaking changes in future updates.

## 如果 AI 和你拥有相同的上下文

Claude 等模型在特定任务（如编码）上已经表现出色。本项目通过持续记录屏幕活动，为模型建立跨时间的工作流记忆。

**3 North Star Metrics:**

- Claude 生成的周/月工作总结具有 95% 以上可用性
- Claude 能提出具有可衡量经济价值的建议
- Claude 能提前发现被忽略的关键决策点

## claude-cobrain 是做什么的？

claude-cobrain 是一个 macOS 后台守护进程，会持续监控活动窗口并生成自然语言摘要。它会：

- 截取当前活动窗口
- 通过本地 VLM 处理截图
- 将带时间戳的摘要追加到 markdown 文件

## 安装

第 1 步 - 添加 marketplace（首次执行）：

```shell
/plugin marketplace add cyrus-cai/claude-cobrain
```

第 2 步 - 安装插件：

```shell
/plugin install claude-cobrain
```

第 3 步 - 部署守护进程：

```shell
/claude-cobrain:cobrain install
```

当前仅支持 macOS。

## 卸载

重要：删除插件前必须先执行 `/claude-cobrain:cobrain uninstall`，停止守护进程并移除 LaunchAgent。否则守护进程会继续在后台运行。

1. `/claude-cobrain:cobrain uninstall` - 停止守护进程并移除 LaunchAgent 与守护进程文件
2. `/plugin uninstall claude-cobrain` - 卸载插件

## 系统要求

| 组件       | 要求               | 目的                                  |
| ---------- | ------------------ | ------------------------------------- |
| 操作系统   | macOS              | 支持 LaunchAgent 与 Accessibility API |
| Python     | 3.11               | 守护进程运行时                        |
| Ollama     | 最新版本           | 本地 LLM 推理服务                     |
| 模型       | qwen3-vl:2b        | 视觉语言模型（2B）                    |
| Python 包  | Pillow, ollama     | 图像处理与 API 客户端                 |
| 磁盘空间   | ~2GB               | 模型与摘要存储                        |
| macOS 权限 | 辅助功能、屏幕录制 | 窗口检测与截图                        |

## 许可证

本项目基于 MIT License 发布，详见 [LICENSE](LICENSE)。
