# Haruna - クラウドQAシステム

Kiro CLIのカスタムエージェントとサブエージェントを使用した階層的なクラウドプロバイダー質問応答システム

## 🏗️ アーキテクチャ

```
orchestrator (トップレベル)
├── aws-qa (AWSオーケストレーター)
│   ├── aws-ec2   → EC2, EBS, ALB, Auto Scaling
│   ├── aws-iam   → IAM, Policies, Roles, Security
│   ├── aws-s3    → S3, Storage, Buckets
│   └── aws-lambda → Lambda, Serverless, Step Functions
├── azure-qa (Azureオーケストレーター)
│   ├── azure-vm       → Virtual Machines, VNet, NSG, Load Balancer
│   ├── azure-storage  → Blob, File, Queue, Table Storage
│   ├── azure-functions → Functions, Logic Apps, Event Grid, Service Bus
│   └── azure-ad       → Azure AD/Entra ID, RBAC, Managed Identity, Key Vault
└── gcp-qa (GCPオーケストレーター)
    ├── gcp-compute    → Compute Engine, GKE, App Engine, Cloud Run
    ├── gcp-storage    → Cloud Storage, Persistent Disk, Cloud SQL, Firestore
    ├── gcp-functions  → Cloud Functions, Cloud Run, Pub/Sub, Cloud Tasks
    └── gcp-iam        → IAM, Service Accounts, Secret Manager, Cloud KMS
```

## 🚀 セットアップ

1. **Kiro CLIのインストール**
   ```bash
   # Kiro CLIが必要です
   # インストール方法は公式ドキュメントを参照
   ```

2. **プロジェクトのクローン**
   ```bash
   git clone <repository-url>
   cd haruna
   ```

3. **エージェントの起動**
   ```bash
   # プロジェクトディレクトリで実行
   # ⚠️ 必ずorchestratorエージェントを指定すること
   kiro-cli chat --agent orchestrator
   ```

   > **重要**: `--agent orchestrator`を指定しないと、サブエージェントへのルーティングが行われず、直接回答モードになります。

## 💡 使用例

### AWS関連の質問
```
EC2、S3、Lambda、IAMそれぞれの主要なCLIコマンドを3つずつ教えて
```

### Azure関連の質問
```
Azure VM、Storage、Functions、ADそれぞれの主要なAzure CLIコマンドを3つずつ教えて
```

### GCP関連の質問
```
Compute Engine、Cloud Storage、Cloud Functions、IAMそれぞれの主要なgcloud CLIコマンドを3つずつ教えて
```

### マルチクラウド比較
```
AWSのS3とAzure Blob Storageの主要なCLIコマンドを3つずつ教えて
```

### 3クラウド並列クエリ
```
AWS S3、Azure Blob Storage、Cloud Storageのバケット作成コマンドを比較して
```

## 📁 プロジェクト構造

```
haruna/
├── AGENTS.md                    # 全エージェント共通設定（日本語応答）
├── README.md                    # このファイル
└── .kiro/
    ├── agents/                  # カスタムエージェント定義
    │   ├── orchestrator.json    # メインオーケストレーター
    │   ├── aws-qa.json         # AWSオーケストレーター
    │   ├── aws-ec2.json        # EC2専門エージェント
    │   ├── aws-iam.json        # IAM専門エージェント
    │   ├── aws-s3.json         # S3専門エージェント
    │   ├── aws-lambda.json     # Lambda専門エージェント
    │   ├── azure-qa.json       # Azureオーケストレーター
    │   ├── azure-vm.json       # Azure VM専門エージェント
    │   ├── azure-storage.json  # Azure Storage専門エージェント
    │   ├── azure-functions.json # Azure Functions専門エージェント
    │   ├── azure-ad.json       # Azure AD専門エージェント
    │   ├── gcp-qa.json         # GCPオーケストレーター
    │   ├── gcp-compute.json    # GCP Compute専門エージェント
    │   ├── gcp-storage.json    # GCP Storage専門エージェント
    │   ├── gcp-functions.json  # GCP Functions専門エージェント
    │   └── gcp-iam.json        # GCP IAM専門エージェント
    └── skills/                  # スキル定義
        ├── aws/
        │   ├── common/          # AWS共通スキル
        │   ├── qa/              # QAルーティングルール
        │   ├── ec2/             # EC2専門スキル
        │   ├── iam/             # IAM専門スキル
        │   ├── s3/              # S3専門スキル
        │   └── lambda/          # Lambda専門スキル
        ├── azure/
        │   ├── common/          # Azure共通スキル
        │   ├── qa/              # QAルーティングルール
        │   ├── vm/              # VM専門スキル
        │   ├── storage/         # Storage専門スキル
        │   ├── functions/       # Functions専門スキル
        │   └── ad/              # AD/Entra ID専門スキル
        └── gcp/
            ├── common/          # GCP共通スキル
            ├── qa/              # QAルーティングルール
            ├── compute/         # Compute専門スキル
            ├── storage/         # Storage専門スキル
            ├── functions/       # Functions専門スキル
            └── iam/             # IAM専門スキル
```

## ⚙️ 設定のポイント

### エージェント設計
- **階層構造**: 親→子→孫の3層サブエージェント呼び出し
- **プロンプト**: 簡潔に保つことで動作が安定
- **スキル読み込み**: `file://`（即時）と`skill://`（オンデマンド）の使い分け

### 品質基準
1. 正確で最新の情報を提供
2. CLIコマンドやIaCコード例を含める
3. 公式ドキュメントを参照
4. 料金と可用性について言及
5. セキュリティのベストプラクティスを強調

## 🔧 開発者向け情報

### デバッグ
- コンテキスト使用率表示: `kiro-cli settings chat.enableContextUsageIndicator true`
- JSON出力確認:
  - AWS: `aws-qa-response.json`
  - Azure: `azure-qa-response.json`
  - GCP: `gcp-qa-response.json`

### カスタマイズ
- 新しいクラウドプロバイダーの追加は`.kiro/agents/`に新しいエージェントを作成
- スキルの追加は`.kiro/skills/`に対応するディレクトリを作成

## 📝 ライセンス

このプロジェクトはKiro CLIのカスタムエージェント機能を活用したデモンストレーションです。

## 🤝 コントリビューション

プルリクエストやイシューの報告を歓迎します。新しいクラウドプロバイダーやサービスの追加提案もお待ちしています。
