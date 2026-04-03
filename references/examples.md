# 多智能体路由配置示例

## 示例 1：两个 WhatsApp 账号 → 两个智能体

```json
{
  "agents": {
    "list": [
      {
        "id": "home",
        "default": true,
        "name": "Home",
        "workspace": "~/.openclaw/workspace-home",
        "agentDir": "~/.openclaw/agents/home/agent"
      },
      {
        "id": "work",
        "name": "Work",
        "workspace": "~/.openclaw/workspace-work",
        "agentDir": "~/.openclaw/agents/work/agent"
      }
    ]
  },
  "bindings": [
    { "agentId": "home", "match": { "channel": "whatsapp", "accountId": "personal" } },
    { "agentId": "work", "match": { "channel": "whatsapp", "accountId": "biz" } }
  ],
  "tools": {
    "agentToAgent": {
      "enabled": true,
      "allow": ["home", "work"]
    }
  }
}
```

## 示例 2：WhatsApp 日常 + Telegram 深度工作

```json
{
  "agents": {
    "list": [
      {
        "id": "chat",
        "name": "Everyday",
        "workspace": "~/.openclaw/workspace-chat",
        "model": "anthropic/claude-sonnet-4-5"
      },
      {
        "id": "opus",
        "name": "Deep Work",
        "workspace": "~/.openclaw/workspace-opus",
        "model": "anthropic/claude-opus-4-5"
      }
    ]
  },
  "bindings": [
    { "agentId": "chat", "match": { "channel": "whatsapp" } },
    { "agentId": "opus", "match": { "channel": "telegram" } }
  ]
}
```

## 示例 3：同一渠道，特定群组路由

```json
{
  "bindings": [
    {
      "agentId": "work",
      "match": {
        "channel": "whatsapp",
        "accountId": "personal",
        "peer": { "kind": "group", "id": "1203630...@g.us" }
      }
    },
    { "agentId": "home", "match": { "channel": "whatsapp" } }
  ]
}
```

## 示例 4：带沙箱限制的智能体

```json
{
  "agents": {
    "list": [
      {
        "id": "main",
        "default": true,
        "workspace": "~/.openclaw/workspace",
        "sandbox": { "mode": "off" }
      },
      {
        "id": "family",
        "workspace": "~/.openclaw/workspace-family",
        "sandbox": {
          "mode": "all",
          "scope": "agent"
        },
        "tools": {
          "allow": ["read", "exec"],
          "deny": ["write", "edit", "apply_patch"]
        }
      }
    ]
  }
}
```
