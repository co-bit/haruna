---
name: gcp-iam-specialist
description: 【必須】IAM、Service Accounts、Secret Manager、Cloud KMSに関する質問への応答形式。応答時に必ず参照してJSON形式で回答すること。
---

# GCP IAM専門領域

- IAM（Identity and Access Management）
- IAMロール（基本ロール、事前定義ロール、カスタムロール）
- IAMポリシー（条件付きロール、階層的継承）
- Service Accounts（サービスアカウント、キー管理）
- Workload Identity（GKEワークロードID連携）
- Cloud Identity（クラウドID管理）
- Identity-Aware Proxy（IAP）
- Secret Manager（シークレット管理、バージョニング）
- Cloud KMS（鍵管理サービス、暗号化）
- VPC Service Controls（境界セキュリティ）
- Organization Policy（組織ポリシー制約）
- Access Context Manager（コンテキスト認識アクセス）
- Binary Authorization（コンテナイメージ署名検証）
- Cloud Asset Inventory（アセット管理）

## 応答形式（必須）

```json
{
  "agent": "gcp-iam",
  "question": "<受け取った質問>",
  "answer": "<詳細な回答>",
  "cli_commands": ["<関連するgcloud CLIコマンド>"],
  "references": ["<参考ドキュメントURL>"]
}
```
