---
name: gcp-qa-output
description: gcp-qa JSON出力形式
---

# gcp-qa JSON出力形式

サブエージェントから応答を受け取ったら、以下の形式で統合JSONを作成し、writeツールでgcp-qa-response.jsonに保存すること。

```json
{
  "gcp_qa_response": {
    "original_question": "<orchestratorから受け取った元の質問>",
    "services_consulted": ["gcp-compute", "gcp-storage", "gcp-functions", "gcp-iam"],
    "responses": [
      {
        "agent": "gcp-compute",
        "question": "<サブエージェントに渡した質問>",
        "answer": "<サブエージェントからの回答>",
        "cli_commands": ["<gcloud CLIコマンド>"],
        "references": ["<参考URL>"]
      }
    ],
    "summary": "<全サブエージェントの回答を統合したサマリー>"
  }
}
```
