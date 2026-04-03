# multi-agent-routing

OpenClaw 多智能体路由配置技能 —— 让多个 AI 智能体在一个网关中协同工作

## 🎯 解决什么痛点

### 问题场景
- 想用一个 Telegram bot 处理个人事务，另一个处理工作事务，但不知道如何隔离
- 多个智能体之间无法通信，数据孤岛
- 配置多智能体路由需要手动编辑 JSON，容易出错
- 没有现成的配置模板和最佳实践参考

### 本技能提供
✅ **一站式配置指南** — 从创建到测试的完整流程  
✅ **开箱即用的配置模板** — agents.list、bindings、agentToAgent  
✅ **快速配置脚本** — 一键完成路由和通信配置  
✅ **4 个真实场景示例** — WhatsApp/Telegram/沙箱限制等  
✅ **避坑指南** — 备份、认证隔离、技能共享等注意事项

## 🚀 快速开始

### 前置条件
- OpenClaw v2026.1.6+
- 已配置的 Telegram/WhatsApp 渠道

### 使用方法

#### 方式 1：使用快速配置脚本
```bash
cd /path/to/this/skill
bash scripts/setup-agent.sh work telegram default
```

#### 方式 2：手动配置
1. 创建智能体：`openclaw agents add work`
2. 编辑 `~/.openclaw/openclaw.json`，添加：
   - `agents.list` — 智能体列表
   - `bindings` — 路由规则
   - `tools.agentToAgent` — 启用智能体间通信
   - `tools.sessions.visibility` — 跨智能体会话访问
3. 重启网关：`openclaw gateway restart`
4. 测试通信：用 `sessions_send` 发送测试消息

详细步骤见 [SKILL.md](SKILL.md)

## 📁 项目结构

```
multi-agent-routing/
├── SKILL.md                  # 完整配置指南（OpenClaw 技能格式）
├── references/
│   └── examples.md           # 4 个真实场景配置示例
├── scripts/
│   └── setup-agent.sh        # 快速配置脚本
└── README.md                 # 本文件
```

## 📋 配置示例

### 双智能体路由（个人 + 工作）
```json
{
  "agents": {
    "list": [
      { "id": "main", "default": true, "workspace": "~/.openclaw/workspace" },
      { "id": "work", "workspace": "~/.openclaw/workspace-work" }
    ]
  },
  "bindings": [
    { "agentId": "work", "match": { "channel": "telegram", "accountId": "default" } },
    { "agentId": "main", "match": { "channel": "telegram", "accountId": "main" } }
  ],
  "tools": {
    "agentToAgent": { "enabled": true, "allow": ["main", "work"] },
    "sessions": { "visibility": "all" }
  }
}
```

更多示例见 [references/examples.md](references/examples.md)

## 🛠️ 技能特性

| 特性 | 说明 |
|------|------|
| 智能体隔离 | 每个智能体独立的工作区、认证、会话 |
| 灵活路由 | 按渠道、账号、群组、私信精确路由 |
| 智能体通信 | 支持 `sessions_send` 跨智能体发消息 |
| 沙箱限制 | 可为不同智能体配置不同的工具权限 |
| 技能共享 | 支持全局技能或每智能体独立技能 |

## ⚠️ 注意事项

1. **配置前备份** — `cp ~/.openclaw/openclaw.json ~/.openclaw/openclaw.json.bak.YYYYMMDD-HHmmss`
2. **不要重用 agentDir** — 会导致认证/会话冲突
3. **手动重启网关** — 配置修改后需要用户手动执行 `openclaw gateway restart`
4. **agentToAgent 默认关闭** — 必须显式启用才能跨智能体通信

## 📚 相关文档

- [OpenClaw 多智能体路由官方文档](https://docs.openclaw.ai/zh-CN/concepts/multi-agent)
- [OpenClaw 沙箱隔离文档](https://docs.openclaw.ai/gateway/sandboxing)
- [OpenClaw Skills 文档](https://docs.openclaw.ai/tools/skills)

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

MIT License

---

**作者**: 彭海泉  
**GitHub**: [@380356797](https://github.com/380356797)  
**Created**: 2026-04-03
