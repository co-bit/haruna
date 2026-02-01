#!/bin/bash
# detect-cloud-provider.sh
#
# ユーザー入力からクラウドプロバイダーを事前検出
# オーケストレーターのルーティング判断をサポート
#
# 入力: STDIN - hook event JSON (userPromptSubmit)
# 出力: STDOUT - 検出結果（コンテキストに追加される）
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

# ユーザープロンプトを取得
PROMPT_RAW=$(echo "$EVENT" | jq -r '.prompt // ""')
PROMPT=$(echo "$PROMPT_RAW" | tr '[:upper:]' '[:lower:]')

# ヘッダー出力
echo "" >> "$LOG_FILE"
echo "[$TIMESTAMP] ╔════════════════════════════════════════════════════════════╗" >> "$LOG_FILE"
echo "[$TIMESTAMP] ║ 🔎 HOOK: detect-cloud-provider.sh                          ║" >> "$LOG_FILE"
echo "[$TIMESTAMP] ╠════════════════════════════════════════════════════════════╣" >> "$LOG_FILE"
echo "[$TIMESTAMP] ║ トリガー: $HOOK_EVENT" >> "$LOG_FILE"
echo "[$TIMESTAMP] ║ 呼び出し元エージェント: $AGENT_NAME" >> "$LOG_FILE"
echo "[$TIMESTAMP] ║ ユーザー入力: $PROMPT_RAW" >> "$LOG_FILE"
echo "[$TIMESTAMP] ╠════════════════════════════════════════════════════════════╣" >> "$LOG_FILE"

# 📩 RAW EVENT をログに出力
echo "[$TIMESTAMP] ║ 📩 RAW EVENT INPUT:" >> "$LOG_FILE"
echo "[$TIMESTAMP] ║ ────────────────────────────────────────────────────────────" >> "$LOG_FILE"
echo "$EVENT" | jq '.' 2>/dev/null | head -100 | while IFS= read -r line; do
  echo "[$TIMESTAMP] ║    $line" >> "$LOG_FILE"
done
echo "[$TIMESTAMP] ║ ────────────────────────────────────────────────────────────" >> "$LOG_FILE"
echo "[$TIMESTAMP] ╠════════════════════════════════════════════════════════════╣" >> "$LOG_FILE"

if [ -z "$PROMPT" ]; then
  echo "[$TIMESTAMP] ║ ⚠️ プロンプトが空のため検出をスキップ                      ║" >> "$LOG_FILE"
  echo "[$TIMESTAMP] ╚════════════════════════════════════════════════════════════╝" >> "$LOG_FILE"
  exit 0
fi

# 検出結果を格納
DETECTED_PROVIDERS=""
DETECTED_SERVICES=""

# AWS検出
if echo "$PROMPT" | grep -qiE '(aws|amazon|ec2|s3|lambda|iam|ebs|alb|nlb|rds|dynamodb|cloudfront|cloudwatch|sns|sqs|ecs|eks|fargate)'; then
  DETECTED_PROVIDERS="${DETECTED_PROVIDERS}AWS, "
  echo "[$TIMESTAMP] ║ ✓ AWS関連キーワード検出" >> "$LOG_FILE"

  if echo "$PROMPT" | grep -qiE '(ec2|ebs|ami|auto.?scaling|alb|nlb|セキュリティグループ|インスタンス)'; then
    DETECTED_SERVICES="${DETECTED_SERVICES}EC2, "
    echo "[$TIMESTAMP] ║   → EC2サービス検出 (ルーティング: aws-qa → aws-ec2)" >> "$LOG_FILE"
  fi
  if echo "$PROMPT" | grep -qiE '(s3|バケット|オブジェクト|ストレージクラス|glacier)'; then
    DETECTED_SERVICES="${DETECTED_SERVICES}S3, "
    echo "[$TIMESTAMP] ║   → S3サービス検出 (ルーティング: aws-qa → aws-s3)" >> "$LOG_FILE"
  fi
  if echo "$PROMPT" | grep -qiE '(lambda|サーバーレス|step.?functions|eventbridge)'; then
    DETECTED_SERVICES="${DETECTED_SERVICES}Lambda, "
    echo "[$TIMESTAMP] ║   → Lambdaサービス検出 (ルーティング: aws-qa → aws-lambda)" >> "$LOG_FILE"
  fi
  if echo "$PROMPT" | grep -qiE '(iam|ポリシー|ロール|権限|mfa|sts)'; then
    DETECTED_SERVICES="${DETECTED_SERVICES}IAM, "
    echo "[$TIMESTAMP] ║   → IAMサービス検出 (ルーティング: aws-qa → aws-iam)" >> "$LOG_FILE"
  fi
fi

# Azure検出
if echo "$PROMPT" | grep -qiE '(azure|microsoft|vm|blob|functions|entra|ad|vnet|nsg)'; then
  DETECTED_PROVIDERS="${DETECTED_PROVIDERS}Azure, "
  echo "[$TIMESTAMP] ║ ✓ Azure関連キーワード検出" >> "$LOG_FILE"

  if echo "$PROMPT" | grep -qiE '(vm|virtual.?machine|vnet|nsg|load.?balancer|scale.?set)'; then
    DETECTED_SERVICES="${DETECTED_SERVICES}VM, "
    echo "[$TIMESTAMP] ║   → VMサービス検出 (ルーティング: azure-qa → azure-vm)" >> "$LOG_FILE"
  fi
  if echo "$PROMPT" | grep -qiE '(blob|storage|file|queue|table|data.?lake)'; then
    DETECTED_SERVICES="${DETECTED_SERVICES}Storage, "
    echo "[$TIMESTAMP] ║   → Storageサービス検出 (ルーティング: azure-qa → azure-storage)" >> "$LOG_FILE"
  fi
  if echo "$PROMPT" | grep -qiE '(functions|logic.?apps|event.?grid|service.?bus)'; then
    DETECTED_SERVICES="${DETECTED_SERVICES}Functions, "
    echo "[$TIMESTAMP] ║   → Functionsサービス検出 (ルーティング: azure-qa → azure-functions)" >> "$LOG_FILE"
  fi
  if echo "$PROMPT" | grep -qiE '(ad|entra|rbac|managed.?identity|key.?vault|サービスプリンシパル)'; then
    DETECTED_SERVICES="${DETECTED_SERVICES}AD, "
    echo "[$TIMESTAMP] ║   → ADサービス検出 (ルーティング: azure-qa → azure-ad)" >> "$LOG_FILE"
  fi
fi

# GCP検出
if echo "$PROMPT" | grep -qiE '(gcp|google.?cloud|compute.?engine|gke|cloud.?storage|cloud.?functions|bigquery|gcs)'; then
  DETECTED_PROVIDERS="${DETECTED_PROVIDERS}GCP, "
  echo "[$TIMESTAMP] ║ ✓ GCP関連キーワード検出" >> "$LOG_FILE"

  if echo "$PROMPT" | grep -qiE '(compute.?engine|gke|app.?engine|cloud.?run|mig)'; then
    DETECTED_SERVICES="${DETECTED_SERVICES}Compute, "
    echo "[$TIMESTAMP] ║   → Computeサービス検出 (ルーティング: gcp-qa → gcp-compute)" >> "$LOG_FILE"
  fi
  if echo "$PROMPT" | grep -qiE '(cloud.?storage|gcs|cloud.?sql|firestore|spanner|bigtable)'; then
    DETECTED_SERVICES="${DETECTED_SERVICES}Storage, "
    echo "[$TIMESTAMP] ║   → Storageサービス検出 (ルーティング: gcp-qa → gcp-storage)" >> "$LOG_FILE"
  fi
  if echo "$PROMPT" | grep -qiE '(cloud.?functions|pub.?sub|cloud.?tasks|workflows|scheduler)'; then
    DETECTED_SERVICES="${DETECTED_SERVICES}Functions, "
    echo "[$TIMESTAMP] ║   → Functionsサービス検出 (ルーティング: gcp-qa → gcp-functions)" >> "$LOG_FILE"
  fi
  if echo "$PROMPT" | grep -qiE '(iam|service.?account|secret.?manager|cloud.?kms|workload.?identity)'; then
    DETECTED_SERVICES="${DETECTED_SERVICES}IAM, "
    echo "[$TIMESTAMP] ║   → IAMサービス検出 (ルーティング: gcp-qa → gcp-iam)" >> "$LOG_FILE"
  fi
fi

echo "[$TIMESTAMP] ╠════════════════════════════════════════════════════════════╣" >> "$LOG_FILE"

# 検出結果の出力
if [ -n "$DETECTED_PROVIDERS" ]; then
  RESULT="🔍 検出: ${DETECTED_PROVIDERS%%, }"
  if [ -n "$DETECTED_SERVICES" ]; then
    RESULT="$RESULT / サービス: ${DETECTED_SERVICES%%, }"
  fi
  echo "[$TIMESTAMP] ║ 📊 検出結果: ${DETECTED_PROVIDERS%%, }" >> "$LOG_FILE"
  echo "[$TIMESTAMP] ║ 📊 サービス: ${DETECTED_SERVICES%%, }" >> "$LOG_FILE"
  echo "$RESULT"
else
  echo "[$TIMESTAMP] ║ ⚠️ クラウドプロバイダー未検出 - 汎用応答モード" >> "$LOG_FILE"
fi

echo "[$TIMESTAMP] ╚════════════════════════════════════════════════════════════╝" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

exit 0
