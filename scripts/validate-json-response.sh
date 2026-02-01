#!/bin/bash
# validate-json-response.sh
#
# サブエージェント応答のJSON形式を検証し、内容をログに記録する
#
# 入力: STDIN - hook event JSON
# 出力: STDOUT - 検証結果メッセージ
# Exit: 0=成功, 1=警告（続行）, 2=ブロック（PreToolUseのみ）

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
TOOL_NAME=$(echo "$EVENT" | jq -r '.tool_name // "unknown"')

# ヘッダー出力
echo "" >> "$LOG_FILE"
echo "[$TIMESTAMP] ╔════════════════════════════════════════════════════════════╗" >> "$LOG_FILE"
echo "[$TIMESTAMP] ║ 🔍 HOOK: validate-json-response.sh                         ║" >> "$LOG_FILE"
echo "[$TIMESTAMP] ╠════════════════════════════════════════════════════════════╣" >> "$LOG_FILE"
echo "[$TIMESTAMP] ║ トリガー: $HOOK_EVENT" >> "$LOG_FILE"
echo "[$TIMESTAMP] ║ 実行エージェント: $AGENT_NAME" >> "$LOG_FILE"
echo "[$TIMESTAMP] ║ 使用ツール: $TOOL_NAME" >> "$LOG_FILE"
echo "[$TIMESTAMP] ╠════════════════════════════════════════════════════════════╣" >> "$LOG_FILE"

# 📩 RAW EVENT をログに出力
echo "[$TIMESTAMP] ║ 📩 RAW EVENT INPUT:" >> "$LOG_FILE"
echo "[$TIMESTAMP] ║ ────────────────────────────────────────────────────────────" >> "$LOG_FILE"
echo "[$TIMESTAMP] ║ 📋 EVENT KEYS:" >> "$LOG_FILE"
echo "$EVENT" | jq -r 'keys[]' 2>/dev/null | while IFS= read -r key; do
  echo "[$TIMESTAMP] ║    - $key" >> "$LOG_FILE"
done
echo "[$TIMESTAMP] ║ ────────────────────────────────────────────────────────────" >> "$LOG_FILE"
echo "[$TIMESTAMP] ║ 📄 FULL EVENT JSON:" >> "$LOG_FILE"
echo "$EVENT" | jq '.' 2>/dev/null | head -100 | while IFS= read -r line; do
  echo "[$TIMESTAMP] ║    $line" >> "$LOG_FILE"
done
echo "[$TIMESTAMP] ║ ────────────────────────────────────────────────────────────" >> "$LOG_FILE"
echo "[$TIMESTAMP] ╠════════════════════════════════════════════════════════════╣" >> "$LOG_FILE"

# tool_inputを抽出（リクエスト情報）
TOOL_INPUT=$(echo "$EVENT" | jq -c '.tool_input // empty' 2>/dev/null)

# tool_inputがある場合、リクエストJSONをログに出力
if [ -n "$TOOL_INPUT" ] && [ "$TOOL_INPUT" != "null" ]; then
  echo "[$TIMESTAMP] ║ 📨 RAW JSON REQUEST:" >> "$LOG_FILE"
  echo "[$TIMESTAMP] ║ ────────────────────────────────────────────────────────────" >> "$LOG_FILE"
  echo "$TOOL_INPUT" | jq '.' 2>/dev/null | while IFS= read -r line; do
    echo "[$TIMESTAMP] ║    $line" >> "$LOG_FILE"
  done
  echo "[$TIMESTAMP] ║ ────────────────────────────────────────────────────────────" >> "$LOG_FILE"
  echo "[$TIMESTAMP] ╠════════════════════════════════════════════════════════════╣" >> "$LOG_FILE"
fi

# tool_responseを抽出（PostToolUse時 - kiro-cli形式）
TOOL_RESPONSE=$(echo "$EVENT" | jq -c '.tool_response // empty' 2>/dev/null)

# 結果がない場合はスキップ
if [ -z "$TOOL_RESPONSE" ] || [ "$TOOL_RESPONSE" = "null" ]; then
  echo "[$TIMESTAMP] ║ ⏭️ tool_responseなし - 検証スキップ" >> "$LOG_FILE"
  echo "[$TIMESTAMP] ╚════════════════════════════════════════════════════════════╝" >> "$LOG_FILE"
  exit 0
fi

# 📩 RAW tool_response をログに出力
echo "[$TIMESTAMP] ║ 📩 RAW TOOL RESPONSE (QA → Orchestrator):" >> "$LOG_FILE"
echo "[$TIMESTAMP] ║ ────────────────────────────────────────────────────────────" >> "$LOG_FILE"
echo "$TOOL_RESPONSE" | jq '.' 2>/dev/null | head -200 | while IFS= read -r line; do
  echo "[$TIMESTAMP] ║    $line" >> "$LOG_FILE"
done
echo "[$TIMESTAMP] ║ ────────────────────────────────────────────────────────────" >> "$LOG_FILE"
echo "[$TIMESTAMP] ╠════════════════════════════════════════════════════════════╣" >> "$LOG_FILE"

# 成功/失敗チェック
SUCCESS=$(echo "$TOOL_RESPONSE" | jq -r '.success // false')
echo "[$TIMESTAMP] ║ 📊 実行結果: success=$SUCCESS" >> "$LOG_FILE"

if [ "$SUCCESS" != "true" ]; then
  OUTPUT="⚠️ サブエージェント実行失敗"
  echo "[$TIMESTAMP] ║ $OUTPUT" >> "$LOG_FILE"
  echo "[$TIMESTAMP] ╚════════════════════════════════════════════════════════════╝" >> "$LOG_FILE"
  echo "$OUTPUT"
  exit 1
fi

# kiro-cli形式: .result[].summaries[] から応答を抽出
SUMMARIES_COUNT=$(echo "$TOOL_RESPONSE" | jq '[.result[].summaries[]] | length' 2>/dev/null || echo "0")
echo "[$TIMESTAMP] ║ 📦 サブエージェント応答数: $SUMMARIES_COUNT 件" >> "$LOG_FILE"
echo "[$TIMESTAMP] ╠════════════════════════════════════════════════════════════╣" >> "$LOG_FILE"

# 各サマリーをログに出力
for i in $(seq 0 $((SUMMARIES_COUNT - 1))); do
  TASK_DESC=$(echo "$TOOL_RESPONSE" | jq -r ".result[0].summaries[$i].taskDescription // \"\"" 2>/dev/null)
  CONTEXT_SUMMARY=$(echo "$TOOL_RESPONSE" | jq -r ".result[0].summaries[$i].contextSummary // \"\"" 2>/dev/null)
  TASK_RESULT=$(echo "$TOOL_RESPONSE" | jq -r ".result[0].summaries[$i].taskResult // \"\"" 2>/dev/null)

  echo "[$TIMESTAMP] ║ ─── サマリー [$((i + 1))/$SUMMARIES_COUNT] ───" >> "$LOG_FILE"
  echo "[$TIMESTAMP] ║ 📝 タスク説明:" >> "$LOG_FILE"
  echo "[$TIMESTAMP] ║    $TASK_DESC" >> "$LOG_FILE"
  echo "[$TIMESTAMP] ║ 📋 コンテキストサマリー:" >> "$LOG_FILE"
  echo "$CONTEXT_SUMMARY" | head -c 500 | while IFS= read -r line; do
    echo "[$TIMESTAMP] ║    $line" >> "$LOG_FILE"
  done
  echo "[$TIMESTAMP] ║ 💬 タスク結果:" >> "$LOG_FILE"
  echo "[$TIMESTAMP] ║ ────────────────────────────────────────────────────────────" >> "$LOG_FILE"
  echo "$TASK_RESULT" | while IFS= read -r line; do
    echo "[$TIMESTAMP] ║    $line" >> "$LOG_FILE"
  done
  echo "[$TIMESTAMP] ║ ────────────────────────────────────────────────────────────" >> "$LOG_FILE"
done

echo "[$TIMESTAMP] ╠════════════════════════════════════════════════════════════╣" >> "$LOG_FILE"

# 呼び出されたサブエージェント情報
CALLED_AGENT=$(echo "$EVENT" | jq -r '.tool_input.content.subagents[0].agent_name // "unknown"' 2>/dev/null)
QUERY=$(echo "$EVENT" | jq -r '.tool_input.content.subagents[0].query // ""' 2>/dev/null)

echo "[$TIMESTAMP] ║ 🎯 呼び出しサブエージェント: $CALLED_AGENT" >> "$LOG_FILE"
echo "[$TIMESTAMP] ║ 📝 クエリ: $QUERY" >> "$LOG_FILE"
echo "[$TIMESTAMP] ╠════════════════════════════════════════════════════════════╣" >> "$LOG_FILE"

OUTPUT="✅ サブエージェント応答OK - $CALLED_AGENT から $SUMMARIES_COUNT 件の応答"

echo "[$TIMESTAMP] ║ $OUTPUT" >> "$LOG_FILE"
echo "[$TIMESTAMP] ╚════════════════════════════════════════════════════════════╝" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

echo "$OUTPUT"

exit 0
