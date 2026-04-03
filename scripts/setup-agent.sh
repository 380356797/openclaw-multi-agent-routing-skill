#!/bin/bash
# 多智能体路由快速配置脚本
# 用法: bash setup-agent.sh <agentId> <channel> [accountId]

set -e

AGENT_ID="${1:?用法: setup-agent.sh <agentId> <channel> [accountId]}"
CHANNEL="${2:?请指定渠道，如 telegram}"
ACCOUNT_ID="${3:-default}"
CONFIG="$HOME/.openclaw/openclaw.json"
BACKUP="$HOME/.openclaw/openclaw.json.bak.$(date +%Y%m%d-%H%M%S)"

echo "📋 多智能体路由配置工具"
echo "========================"
echo "智能体ID: $AGENT_ID"
echo "渠道: $CHANNEL"
echo "账号: $ACCOUNT_ID"
echo ""

# 备份
echo "📦 备份配置到 $BACKUP"
cp "$CONFIG" "$BACKUP"

# 用向导创建智能体
echo "🔧 请运行以下命令创建智能体（交互式向导）:"
echo "  openclaw agents add $AGENT_ID"
echo ""
echo "创建完成后，脚本会自动配置路由和通信。"
echo ""

# 检查智能体是否已存在
if python3 -c "
import json
with open('$CONFIG') as f:
    d = json.load(f)
agents = d.get('agents', {}).get('list', [])
if any(a.get('id') == '$AGENT_ID' for a in agents):
    exit(0)
exit(1)
" 2>/dev/null; then
    echo "✅ 智能体 $AGENT_ID 已存在，配置路由..."
else
    echo "⚠️  智能体 $AGENT_ID 尚未创建，请先运行 openclaw agents add $AGENT_ID"
    exit 1
fi

# 配置 agentToAgent 和 sessions.visibility
python3 << 'PYEOF'
import json, sys

config_path = sys.argv[1] if len(sys.argv) > 1 else "$CONFIG"
agent_id = sys.argv[2] if len(sys.argv) > 2 else "$AGENT_ID"
channel = sys.argv[3] if len(sys.argv) > 3 else "$CHANNEL"
account_id = sys.argv[4] if len(sys.argv) > 4 else "$ACCOUNT_ID"

with open(config_path) as f:
    config = json.load(f)

# 确保 tools 存在
if "tools" not in config:
    config["tools"] = {}

# 配置 agentToAgent
if "agentToAgent" not in config["tools"]:
    config["tools"]["agentToAgent"] = {"enabled": True, "allow": []}

allow = config["tools"]["agentToAgent"].get("allow", [])
if "main" not in allow:
    allow.append("main")
if agent_id not in allow:
    allow.append(agent_id)
config["tools"]["agentToAgent"]["allow"] = allow
config["tools"]["agentToAgent"]["enabled"] = True

# 配置 sessions.visibility
if "sessions" not in config["tools"]:
    config["tools"]["sessions"] = {}
config["tools"]["sessions"]["visibility"] = "all"

# 确保 bindings 存在并添加路由
if "bindings" not in config:
    config["bindings"] = []

# 检查是否已有该路由
new_binding = {"agentId": agent_id, "match": {"channel": channel, "accountId": account_id}}
if not any(
    b.get("agentId") == agent_id and
    b.get("match", {}).get("channel") == channel and
    b.get("match", {}).get("accountId") == account_id
    for b in config["bindings"]
):
    config["bindings"].insert(0, new_binding)

with open(config_path, "w") as f:
    json.dump(config, f, indent=2, ensure_ascii=False)

print("✅ 配置更新完成！")
PYEOF

echo ""
echo "🎉 配置完成！请重启网关："
echo "  openclaw gateway restart"
echo ""
echo "验证配置："
echo "  openclaw agents list --bindings"
