# Cloud QA System

## 必須ルール

### 言語
全ての応答は日本語で行うこと。

### 応答形式

#### サブエージェント応答（JSON必須）
aws-ec2, aws-iam, aws-s3, aws-lambda, azure-vm, azure-storage, azure-functions, azure-ad, gcp-compute, gcp-storage, gcp-functions, gcp-iamは以下の形式で応答すること：

```json
{
  "agent": "<エージェント名>",
  "question": "<受け取った質問>",
  "answer": "<詳細な回答>",
  "cli_commands": ["<CLIコマンド例>"],
  "references": ["<参考ドキュメントURL>"]
}
```

#### オーケストレーター応答（JSON必須）
aws-qa, azure-qa, gcp-qaはサブエージェントの応答を統合し、以下の形式で出力すること：

```json
{
  "{cloud}_qa_response": {
    "original_question": "<元の質問>",
    "services_consulted": ["<使用したサブエージェント>"],
    "responses": [<各サブエージェントのJSON>],
    "summary": "<統合サマリー>"
  }
}
```

#### トップレベル応答
orchestratorはユーザーに対して人間が読みやすい日本語で応答すること。

---

## ルーティングルール

### クラウドプロバイダー別（orchestrator用）
| キーワード | ルーティング先 |
|-----------|---------------|
| AWS, Amazon, EC2, S3, Lambda, IAM, EBS, ALB | aws-qa |
| Azure, Microsoft, VM, Blob, Functions, AD, Entra | azure-qa |
| GCP, Google Cloud, Compute Engine, Cloud Storage, Cloud Functions | gcp-qa |

### AWSサービス別（aws-qa用）
| キーワード | ルーティング先 |
|-----------|---------------|
| EC2, EBS, AMI, Auto Scaling, ALB, NLB, セキュリティグループ, Launch Template | aws-ec2 |
| IAM, ポリシー, ロール, ユーザー, グループ, MFA, STS | aws-iam |
| S3, バケット, オブジェクト, ライフサイクル, バージョニング | aws-s3 |
| Lambda, サーバーレス, Step Functions, EventBridge, API Gateway | aws-lambda |

### Azureサービス別（azure-qa用）
| キーワード | ルーティング先 |
|-----------|---------------|
| VM, Virtual Machine, VNet, NSG, Load Balancer, App Gateway, Scale Set | azure-vm |
| Storage, Blob, File, Queue, Table, Data Lake | azure-storage |
| Functions, Logic Apps, Event Grid, Service Bus, Durable Functions | azure-functions |
| AD, Entra ID, RBAC, Managed Identity, Key Vault, サービスプリンシパル | azure-ad |

### GCPサービス別（gcp-qa用）
| キーワード | ルーティング先 |
|-----------|---------------|
| Compute Engine, GKE, App Engine, Cloud Run, MIG, Persistent Disk | gcp-compute |
| Cloud Storage, GCS, Filestore, Cloud SQL, Spanner, Firestore, Bigtable | gcp-storage |
| Cloud Functions, Pub/Sub, Cloud Tasks, Scheduler, Eventarc, Workflows | gcp-functions |
| IAM, Service Account, Workload Identity, Secret Manager, Cloud KMS | gcp-iam |

### 複数サービスにまたがる質問
関連する複数のサブエージェントを並列で呼び出し、統合して回答すること。

---

## 品質基準

1. **正確性**: 最新の公式情報に基づく回答
2. **実用性**: CLIコマンドやIaCコード例を含める
3. **参照性**: 公式ドキュメントURLを提供
4. **コスト意識**: 料金と可用性について言及
5. **セキュリティ**: ベストプラクティスを強調

---

## アーキテクチャ

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
│   ├── azure-functions → Functions, Logic Apps, Event Grid
│   └── azure-ad       → Azure AD/Entra ID, RBAC, Managed Identity
└── gcp-qa (GCPオーケストレーター)
    ├── gcp-compute    → Compute Engine, GKE, App Engine, Cloud Run
    ├── gcp-storage    → Cloud Storage, Persistent Disk, Cloud SQL
    ├── gcp-functions  → Cloud Functions, Cloud Run, Pub/Sub
    └── gcp-iam        → IAM, Service Accounts, Secret Manager
```
