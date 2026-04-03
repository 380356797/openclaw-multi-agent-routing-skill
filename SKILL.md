---
name: multi-agent-routing
description: "创建和配置 OpenClaw 多智能体路由系统。当用户要求创建新智能体、配置多智能体路由、实现智能体间通信、添加 agentToAgent 配置时触发。触发关键词：创建智能体、多智能体、路由、agent routing、agentToAgent、智能体通信。"
---

# 多智能体路由

## 核心概念

一个**智能体**是一个完全独立的大脑，拥有自己的：
- **工作区**（`~/.openclaw/workspace-<agentId>`）
- **状态目录**（`~/.openclaw/agents/<agentId>/agent`）
- **会话存储**（`~/.openclaw/agents/<agentId>/sessions`）

## 创建流程

### 步骤 1：用向导创建智能体

```bash
openclaw agents add <agentId>
```

向导会自动创建目录结构。按提示选择渠道配置。

### 步骤 2：配置 openclaw.json

在 `~/.openclaw/openclaw.json` 中添加/修改以下字段：

#### agents.list

```json
{
  "agents": {
    "list": [
      {
        "id": "main",
        "default": true,
        "name": "主智能体",
        "workspace": "~/.openclaw/workspace",
        "agentDir": "~/.openclaw/agents/main/agent"
      },
      {
        "id": "<agentId>",
        "name": "<智能体名称>",
        "workspace": "~/.openclaw/workspace-<agentId>",
        "agentDir": "~/.openclaw/agents/<agentId>/agent"
      }
    ]
  }
}
```

#### bindings（路由规则）

路由优先级从高到低：
1. `peer` 匹配（精确私信/群组 ID）
2. `guildId`（Discord）/ `teamId`（Slack）
3. `accountId` 匹配
4. 渠道级匹配
5. 回退到默认智能体

```json
{
  "bindings": [
    { "agentId": "<agentId>", "match": { "channel": "<channel>", "accountId": "<accountId>" } },
    { "agentId": "main", "match": { "channel": "<channel>" } }
  ]
}
```

#### tools.agentToAgent（智能体间通信）

**必须显式启用**，默认关闭：

```json
{
  "tools": {
    "agentToAgent": {
      "enabled": true,
      "allow": ["main", "<agentId>"]
    }
  }
}
```

#### tools.sessions.visibility（跨智能体会话访问）

```json
{
  "tools": {
    "sessions": {
      "visibility": "all"
    }
  }
}
```

### 步骤 3：验证配置

```bash
openclaw agents list --bindings
```

### 步骤 4：重启网关

⚠️ **必须由用户手动执行**（会断开连接）：

```bash
openclaw gateway restart
```

### 步骤 5：测试通信

用 `sessions_send` 测试智能体间通信：

```
sessions_send({
  sessionKey: "agent:<agentId>:telegram:direct:<peerId>",
  message: "测试消息"
})
```

## 注意事项

- 改配置前必须备份：`cp ~/.openclaw/openclaw.json ~/.openclaw/openclaw.json.bak.YYYYMMDD-HHmmss`
- 不能重用 `agentDir`，会导致认证/会话冲突
- 认证配置是每智能体独立的，需要手动复制 `auth-profiles.json`
- Skills 可通过 `~/.openclaw/skills` 共享，或放在各智能体工作区的 `skills/` 下独享
- `agentToAgent` 不开启则智能体间无法通信
- `sessions.visibility` 不设为 `all` 则无法跨智能体访问会话

## 常见场景

### 场景 1：个人 + 工作双智能体

不同 Telegram bot 账号路由到不同智能体。

### 场景 2：同一渠道不同群组路由

```json
{
  "bindings": [
    { "agentId": "work", "match": { "channel": "telegram", "peer": { "kind": "group", "id": "<groupId>" } } },
    { "agentId": "main", "match": { "channel": "telegram" } }
  ]
}
```

### 场景 3：不同渠道不同智能体

```json
{
  "bindings": [
    { "agentId": "main", "match": { "channel": "telegram" } },
    { "agentId": "work", "match": { "channel": "whatsapp" } }
  ]
}
```
