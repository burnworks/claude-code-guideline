#!/bin/bash
# ~/.claude/hooks/block_dangerous.sh
#
# PreToolUse Hooks: Bash ツールの危険コマンドをブロックする
# ブロック時は exit 0 + JSON 出力（permissionDecision: "deny"）を使用
# JSON パースに python3 を使用（macOS / Ubuntu に標準搭載）

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    print(data.get('tool_input', {}).get('command', ''))
except Exception:
    print('')
" 2>/dev/null)

DANGEROUS_PATTERNS=(
  "rm -rf /"
  "rm -rf ~"
  "rm -rf *"
  "sudo rm"
  "mkfs"
  "> /dev/sd"
)

for pattern in "${DANGEROUS_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qF "$pattern"; then
    python3 -c "
import json, sys
print(json.dumps({
    'hookSpecificOutput': {
        'hookEventName': 'PreToolUse',
        'permissionDecision': 'deny',
        'permissionDecisionReason': '危険なコマンドパターンを検出しました: $pattern'
    }
}))
"
    exit 0
  fi
done

exit 0