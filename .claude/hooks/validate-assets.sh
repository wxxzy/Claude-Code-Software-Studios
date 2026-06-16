#!/bin/bash
# Claude Code PostToolUse hook: 写入后安全约束扫描
# 触发时机: Write 或 Edit 工具调用完成后
# 扫描范围: 硬编码密钥、高危执行模式
# Exit 0 = 允许 (扫描结果记录到日志，不阻断写入)
#
# Input schema (PostToolUse for Write/Edit):
# { "tool_name": "Write", "tool_input": { "file_path": "...", "content": "..." } }

INPUT=$(cat)

# 解析写入的文件路径
if command -v jq >/dev/null 2>&1; then
    FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty')
else
    FILE_PATH=$(echo "$INPUT" | grep -oE '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/"file_path"[[:space:]]*:[[:space:]]*"//;s/"$//')
fi

[ -z "$FILE_PATH" ] && exit 0
[ ! -f "$FILE_PATH" ] && exit 0

# 跳过日志、二进制、配置文件自身
case "$FILE_PATH" in
    *.log|*.png|*.jpg|*.gif|*.zip|*.tar|*.gz) exit 0 ;;
    .claude/hooks/*|.claude/settings.json) exit 0 ;;
esac

ALERTS=""

# --- 检查1: 硬编码密钥模式 ---
# 匹配: api_key = "sk-abc123xyz..." 类赋值（排除占位符 ${ } 和测试哑值）
if grep -qiE '(api_key|apikey|api_secret|secret_key|password|passwd|token|access_key)\s*[=:]\s*["\x27][^$\{][^"'"'"']{8,}["\x27]' "$FILE_PATH" 2>/dev/null; then
    ALERTS="$ALERTS\n[SECURITY] Possible hardcoded credential in: $FILE_PATH"
fi

# --- 检查2: 高危执行模式（仅 src/ 目录下） ---
if echo "$FILE_PATH" | grep -qE '^src/'; then
    # Python: eval(), exec(), subprocess with shell=True
    if grep -qE '\beval\s*\(|\bexec\s*\(|subprocess\.[a-z]+\(.*shell\s*=\s*True' "$FILE_PATH" 2>/dev/null; then
        ALERTS="$ALERTS\n[SECURITY] High-risk execution pattern detected in: $FILE_PATH (eval/exec/shell=True)"
    fi
    # JavaScript/TypeScript: eval(), new Function(), child_process with shell
    if grep -qE '\beval\s*\(|new\s+Function\s*\(|exec\s*\(.*\bshell\b' "$FILE_PATH" 2>/dev/null; then
        ALERTS="$ALERTS\n[SECURITY] High-risk JS execution pattern in: $FILE_PATH (eval/new Function)"
    fi
fi

# --- 检查3: .env 文件直接写入保护 ---
case "$FILE_PATH" in
    .env|.env.*|*/.env|*/.env.*)
        ALERTS="$ALERTS\n[SECURITY] Writing to .env file: $FILE_PATH — ensure no secrets committed to git"
        ;;
esac

# --- 记录与输出 ---
if [ -n "$ALERTS" ]; then
    LOG_DIR="production/session-logs"
    mkdir -p "$LOG_DIR"
    LOG_FILE="$LOG_DIR/security-alerts.log"
    echo -e "[$(date '+%Y-%m-%d %H:%M:%S')]$ALERTS" >> "$LOG_FILE"
    echo -e "=== USDS Security Scan ===$ALERTS\n⚠️  Check $LOG_FILE for history\n=========================" >&2
fi

exit 0
