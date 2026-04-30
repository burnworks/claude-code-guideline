#!/bin/bash
# ~/.claude/hooks/block_dangerous.sh
#
# PreToolUse Hooks: Bash ツールの危険コマンドをブロックする
# exit 0 = 許可, exit 2 = ブロック
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
    echo "[BLOCKED] 危険なコマンドパターンを検出しました: $pattern" >&2
    exit 2
  fi
done

exit 0