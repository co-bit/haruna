#!/bin/bash
# validate-orchestrator-response.sh
#
# オーケストレーター応答の統合形式を検証する
#
# 入力: STDIN - hook event JSON
# 出力: STDOUT - 検証結果メッセージ
# Exit: 0=成功, 1=警告（続行）

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

# ヘッダー出力
echo "" >> "$LOG_FILE"
echo "[$TIMESTAMP] ╔════════════════════════════════════════════════════════════╗" >> "$LOG_FILE"
echo "[$TIMESTAMP] ║ 📊 HOOK: validate-orchestrator-response.sh                 ║" >> "$LOG_FILE"
echo "[$TIMESTAMP] ╠════════════════════════════════════════════════════════════╣" >> "$LOG_FILE"
echo "[$TIMESTAMP] ║ トリガー: $HOOK_EVENT" >> "$LOG_FILE"
echo "[$TIMESTAMP] ║ オーケストレーター: $AGENT_NAME" >> "$LOG_FILE"
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

# tool_resultを抽出
RESULT=$(echo "$EVENT" | jq -r '.tool_result // empty' 2>/dev/null)

# 結果がない場合はスキップ
if [ -z "$RESULT" ]; then
  echo "[$TIMESTAMP] ║ ⏭️ tool_resultなし - 検証スキップ" >> "$LOG_FILE"
  echo "[$TIMESTAMP] ╚════════════════════════════════════════════════════════════╝" >> "$LOG_FILE"
  exit 0
fi

# 📩 RAW JSON RESPONSE をログに出力（検証前）
echo "[$TIMESTAMP] ║ 📩 RAW ORCHESTRATOR RESPONSE:" >> "$LOG_FILE"
echo "[$TIMESTAMP] ║ ────────────────────────────────────────────────────────────" >> "$LOG_FILE"
if echo "$RESULT" | jq -e '.' > /dev/null 2>&1; then
  # JSONの場合は整形して出力
  echo "$RESULT" | jq '.' 2>/dev/null | while IFS= read -r line; do
    echo "[$TIMESTAMP] ║    $line" >> "$LOG_FILE"
  done
else
  # JSON以外の場合はそのまま出力（先頭1000文字）
  echo "$RESULT" | head -c 1000 | while IFS= read -r line; do
    echo "[$TIMESTAMP] ║    $line" >> "$LOG_FILE"
  done
fi
echo "[$TIMESTAMP] ║ ────────────────────────────────────────────────────────────" >> "$LOG_FILE"
echo "[$TIMESTAMP] ╠════════════════════════════════════════════════════════════╣" >> "$LOG_FILE"

# JSON形式かチェック
if ! echo "$RESULT" | jq -e '.' > /dev/null 2>&1; then
  OUTPUT="❌ オーケストレーター応答がJSON形式ではありません"
  echo "[$TIMESTAMP] ║ $OUTPUT" >> "$LOG_FILE"
  echo "[$TIMESTAMP] ╚════════════════════════════════════════════════════════════╝" >> "$LOG_FILE"
  echo "$OUTPUT"
  exit 1
fi

# *_qa_response形式のチェック（aws_qa_response, azure_qa_response, gcp_qa_response）
QA_RESPONSE=$(echo "$RESULT" | jq -r 'keys[] | select(endswith("_qa_response"))' 2>/dev/null | head -1)

if [ -z "$QA_RESPONSE" ]; then
  # 単一サブエージェント応答の場合はスキップ
  if echo "$RESULT" | jq -e '.agent' > /dev/null 2>&1; then
    AGENT=$(echo "$RESULT" | jq -r '.agent')
    echo "[$TIMESTAMP] ║ ⏭️ 単一サブエージェント応答 ($AGENT) - オーケストレーター検証スキップ" >> "$LOG_FILE"
    echo "[$TIMESTAMP] ╚════════════════════════════════════════════════════════════╝" >> "$LOG_FILE"
    exit 0
  fi
  OUTPUT="❌ オーケストレーター応答形式が不正（*_qa_response キーが必要）"
  echo "[$TIMESTAMP] ║ $OUTPUT" >> "$LOG_FILE"
  echo "[$TIMESTAMP] ╚════════════════════════════════════════════════════════════╝" >> "$LOG_FILE"
  echo "$OUTPUT"
  exit 1
fi

echo "[$TIMESTAMP] ║ 📦 応答タイプ: $QA_RESPONSE" >> "$LOG_FILE"
echo "[$TIMESTAMP] ╠════════════════════════════════════════════════════════════╣" >> "$LOG_FILE"

# 必須フィールドチェック
ORIGINAL_QUESTION=$(echo "$RESULT" | jq -r ".[\"$QA_RESPONSE\"].original_question // empty")
SERVICES_CONSULTED=$(echo "$RESULT" | jq -c ".[\"$QA_RESPONSE\"].services_consulted // []")
RESPONSES=$(echo "$RESULT" | jq -c ".[\"$QA_RESPONSE\"].responses // []")
SUMMARY=$(echo "$RESULT" | jq -r ".[\"$QA_RESPONSE\"].summary // empty")

echo "[$TIMESTAMP] ║ 📝 元の質問: $ORIGINAL_QUESTION" >> "$LOG_FILE"
echo "[$TIMESTAMP] ║ 🔄 参照したサービス: $SERVICES_CONSULTED" >> "$LOG_FILE"
echo "[$TIMESTAMP] ╠════════════════════════════════════════════════════════════╣" >> "$LOG_FILE"

# 各サブエージェント応答を表示
RESPONSE_COUNT=$(echo "$RESULT" | jq -r ".[\"$QA_RESPONSE\"].responses | length" 2>/dev/null || echo "0")
echo "[$TIMESTAMP] ║ 📊 統合された応答数: $RESPONSE_COUNT 件" >> "$LOG_FILE"

for i in $(seq 0 $((RESPONSE_COUNT - 1))); do
  SUB_AGENT=$(echo "$RESULT" | jq -r ".[\"$QA_RESPONSE\"].responses[$i].agent // \"unknown\"")
  SUB_QUESTION=$(echo "$RESULT" | jq -r ".[\"$QA_RESPONSE\"].responses[$i].question // \"\"" | head -c 50)
  echo "[$TIMESTAMP] ║   [$((i + 1))] $SUB_AGENT: $SUB_QUESTION..." >> "$LOG_FILE"
done

echo "[$TIMESTAMP] ╠════════════════════════════════════════════════════════════╣" >> "$LOG_FILE"

if [ -n "$SUMMARY" ]; then
  echo "[$TIMESTAMP] ║ 📋 サマリー:" >> "$LOG_FILE"
  echo "$SUMMARY" | head -c 300 | while IFS= read -r line; do
    echo "[$TIMESTAMP] ║    $line" >> "$LOG_FILE"
  done
  echo "[$TIMESTAMP] ╠════════════════════════════════════════════════════════════╣" >> "$LOG_FILE"
fi

MISSING=""
if [ -z "$ORIGINAL_QUESTION" ]; then
  MISSING="${MISSING}original_question, "
fi
if [ "$SERVICES_CONSULTED" = "[]" ] || [ -z "$SERVICES_CONSULTED" ]; then
  MISSING="${MISSING}services_consulted, "
fi
if [ "$RESPONSES" = "[]" ] || [ -z "$RESPONSES" ]; then
  MISSING="${MISSING}responses, "
fi

if [ -n "$MISSING" ]; then
  OUTPUT="❌ オーケストレーター応答に必須フィールドが不足: ${MISSING%%, }"
  echo "[$TIMESTAMP] ║ $OUTPUT" >> "$LOG_FILE"
  echo "[$TIMESTAMP] ╚════════════════════════════════════════════════════════════╝" >> "$LOG_FILE"
  echo "$OUTPUT"
  exit 1
fi

# 統合されたサービス数をカウント
SERVICE_COUNT=$(echo "$RESULT" | jq -r ".[\"$QA_RESPONSE\"].services_consulted | length" 2>/dev/null)

OUTPUT="✅ オーケストレーター応答OK - ${SERVICE_COUNT}サービス統合, ${RESPONSE_COUNT}件の応答"
echo "[$TIMESTAMP] ║ $OUTPUT" >> "$LOG_FILE"
echo "[$TIMESTAMP] ╚════════════════════════════════════════════════════════════╝" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

echo "$OUTPUT"

exit 0
