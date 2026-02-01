#!/bin/bash
# log-session.sh
#
# セッション開始/終了をログに記録する
#
# 入力: STDIN - hook event JSON
# 出力: STDOUT - ログメッセージ
# Exit: 0=成功

set -e

# ログファイル設定
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
LOG_FILE="${PROJECT_DIR}/hooks-execution.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# STDINからイベントを読み取り
EVENT=$(cat)

# イベント情報を抽出
HOOK_EVENT=$(echo "$EVENT" | jq -r '.hook_event_name // "unknown"')
AGENT_NAME=$(echo "$EVENT" | jq -r '.agent_name // "unknown"')
CWD=$(echo "$EVENT" | jq -r '.cwd // "unknown"')

# ヘッダー出力
echo "" >> "$LOG_FILE"
echo "[$TIMESTAMP] ╔════════════════════════════════════════════════════════════╗" >> "$LOG_FILE"
echo "[$TIMESTAMP] ║ 🎯 HOOK: log-session.sh                                    ║" >> "$LOG_FILE"
echo "[$TIMESTAMP] ╠════════════════════════════════════════════════════════════╣" >> "$LOG_FILE"
echo "[$TIMESTAMP] ║ トリガー: $HOOK_EVENT" >> "$LOG_FILE"
echo "[$TIMESTAMP] ║ エージェント: $AGENT_NAME" >> "$LOG_FILE"
echo "[$TIMESTAMP] ║ 作業ディレクトリ: $CWD" >> "$LOG_FILE"
echo "[$TIMESTAMP] ╠════════════════════════════════════════════════════════════╣" >> "$LOG_FILE"

# 📩 RAW EVENT をログに出力
echo "[$TIMESTAMP] ║ 📩 RAW EVENT INPUT:" >> "$LOG_FILE"
echo "[$TIMESTAMP] ║ ────────────────────────────────────────────────────────────" >> "$LOG_FILE"
echo "$EVENT" | jq '.' 2>/dev/null | head -100 | while IFS= read -r line; do
  echo "[$TIMESTAMP] ║    $line" >> "$LOG_FILE"
done
echo "[$TIMESTAMP] ║ ────────────────────────────────────────────────────────────" >> "$LOG_FILE"
echo "[$TIMESTAMP] ╠════════════════════════════════════════════════════════════╣" >> "$LOG_FILE"

case "$HOOK_EVENT" in
  "agentSpawn")
    echo "[$TIMESTAMP] ║ 🚀 セッション開始                                          ║" >> "$LOG_FILE"
    echo "[$TIMESTAMP] ║    エージェント「$AGENT_NAME」が起動しました" >> "$LOG_FILE"
    RESULT="🚀 Agent起動: $AGENT_NAME"
    ;;
  "stop")
    echo "[$TIMESTAMP] ║ 🏁 セッション終了                                          ║" >> "$LOG_FILE"
    echo "[$TIMESTAMP] ║    エージェント「$AGENT_NAME」が終了しました" >> "$LOG_FILE"
    RESULT="🏁 Agent終了: $AGENT_NAME"
    ;;
  "userPromptSubmit")
    PROMPT_PREVIEW=$(echo "$EVENT" | jq -r '.prompt // ""' | head -c 80)
    echo "[$TIMESTAMP] ║ 📝 ユーザー入力受信                                        ║" >> "$LOG_FILE"
    echo "[$TIMESTAMP] ║    入力内容: ${PROMPT_PREVIEW}..." >> "$LOG_FILE"
    RESULT="📝 ユーザー入力: ${PROMPT_PREVIEW}..."
    ;;
  *)
    echo "[$TIMESTAMP] ║ 📌 その他イベント: $HOOK_EVENT                             ║" >> "$LOG_FILE"
    RESULT="📌 イベント: $HOOK_EVENT"
    ;;
esac

echo "[$TIMESTAMP] ╚════════════════════════════════════════════════════════════╝" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

echo "$RESULT"

exit 0
