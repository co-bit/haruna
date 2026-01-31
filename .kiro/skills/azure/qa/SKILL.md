---
name: azure-qa-routing
description: Azure質問のサブエージェントルーティングルール
---

# Azureサブエージェントルーティング

## 質問内容に応じたサブエージェント選択

### azure-vm
- Virtual Machines（VM、仮想マシン）
- Virtual Network（VNet、ネットワーク）
- Network Security Groups（NSG）
- Load Balancer、Application Gateway
- VM Scale Sets、Availability Sets
- Managed Disks、Disk Encryption

### azure-storage
- Blob Storage（ブロブ、コンテナー）
- File Storage（ファイル共有）
- Queue Storage（キュー）
- Table Storage（テーブル）
- Storage Account（アカウント、冗長性）
- Azure Data Lake Storage

### azure-functions
- Azure Functions（関数アプリ）
- Logic Apps（ロジックアプリ）
- Event Grid（イベントグリッド）
- Service Bus（サービスバス）
- API Management
- Durable Functions

### azure-ad
- Azure Active Directory / Entra ID
- マネージドID（Managed Identity）
- RBAC（ロールベースアクセス制御）
- Azure Key Vault
- Conditional Access（条件付きアクセス）
- サービスプリンシパル

## 複数サービスにまたがる質問

複数のサブエージェントを並列で呼び出し、統合して回答すること。
