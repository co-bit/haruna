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
├── azure-qa (Azure専門) + Microsoft Learn MCP
└── gcp-qa (GCP専門)
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

3. **エージェントの初期化**
   ```bash
   # プロジェクトディレクトリで実行
   kiro-cli chat
   ```

## 💡 使用例

### AWS関連の質問
```
EC2、S3、Lambda、IAMそれぞれの主要なCLIコマンドを3つずつ教えて
```

### マルチクラウド比較
```
AWSのS3とAzure Blob Storageの主要なCLIコマンドを3つずつ教えて
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
    │   ├── azure-qa.json       # Azure専門エージェント
    │   └── gcp-qa.json         # GCP専門エージェント
    └── skills/                  # スキル定義
        └── aws/
            ├── common/          # AWS共通スキル
            ├── qa/              # QAルーティングルール
            ├── qa-output/       # JSON出力形式
            ├── ec2/             # EC2専門スキル
            ├── iam/             # IAM専門スキル
            ├── s3/              # S3専門スキル
            └── lambda/          # Lambda専門スキル
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
- JSON出力確認: `aws-qa-response.json`ファイルを参照

### カスタマイズ
- 新しいクラウドプロバイダーの追加は`.kiro/agents/`に新しいエージェントを作成
- スキルの追加は`.kiro/skills/`に対応するディレクトリを作成

## 📝 ライセンス

このプロジェクトはKiro CLIのカスタムエージェント機能を活用したデモンストレーションです。

## 🤝 コントリビューション

プルリクエストやイシューの報告を歓迎します。新しいクラウドプロバイダーやサービスの追加提案もお待ちしています。
