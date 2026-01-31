---
name: gcp-qa-routing
description: GCP質問のサブエージェントルーティングルール
---

# GCPサブエージェントルーティング

## 質問内容に応じたサブエージェント選択

### gcp-compute
- Compute Engine（VM、インスタンス）
- Google Kubernetes Engine（GKE、コンテナ）
- App Engine（GAE、マネージドアプリ）
- Cloud Run（コンテナサーバーレス）
- Persistent Disk（永続ディスク）
- VPC Network（ネットワーク、サブネット）
- Cloud Load Balancing（ロードバランサー）
- Managed Instance Groups（MIG）

### gcp-storage
- Cloud Storage（GCS、バケット、オブジェクト）
- Persistent Disk（永続ディスク、スナップショット）
- Filestore（NFSファイルストレージ）
- Cloud SQL（マネージドデータベース）
- Cloud Spanner（分散データベース）
- Cloud Bigtable（NoSQL）
- Firestore（ドキュメントDB）

### gcp-functions
- Cloud Functions（サーバーレス関数）
- Cloud Run（コンテナサーバーレス）
- Pub/Sub（メッセージング）
- Cloud Tasks（タスクキュー）
- Cloud Scheduler（スケジューラー）
- Eventarc（イベント駆動）
- Workflows（ワークフローオーケストレーション）

### gcp-iam
- IAM（Identity and Access Management）
- Service Accounts（サービスアカウント）
- Workload Identity（ワークロードID）
- Cloud Identity（クラウドID）
- Secret Manager（シークレット管理）
- Cloud KMS（鍵管理サービス）
- Organization Policy（組織ポリシー）
- Access Context Manager（アクセスコンテキスト）

## 複数サービスにまたがる質問

複数のサブエージェントを並列で呼び出し、統合して回答すること。
