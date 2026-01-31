---
name: azure-qa-output
description: azure-qa JSON出力形式
---

# azure-qa JSON出力形式

サブエージェントから応答を受け取ったら、以下の形式で統合JSONを作成し、writeツールでazure-qa-response.jsonに保存すること。

```json
{
  "azure_qa_response": {
    "original_question": "<orchestratorから受け取った元の質問>",
    "services_consulted": ["azure-vm", "azure-storage", "azure-functions", "azure-ad"],
    "responses": [
      {
        "agent": "azure-vm",
        "question": "<サブエージェントに渡した質問>",
        "answer": "<サブエージェントからの回答>",
        "cli_commands": ["<Azure CLIコマンド>"],
        "references": ["<参考URL>"]
      }
    ],
    "summary": "<全サブエージェントの回答を統合したサマリー>"
  }
}
```
