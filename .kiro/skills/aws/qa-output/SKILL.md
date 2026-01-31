---
name: aws-qa-output
description: aws-qa JSON出力形式
---

# aws-qa JSON出力形式

サブエージェントから応答を受け取ったら、以下の形式で統合JSONを作成し、writeツールでaws-qa-response.jsonに保存すること。

```json
{
  "aws_qa_response": {
    "original_question": "<orchestratorから受け取った元の質問>",
    "services_consulted": ["aws-ec2", "aws-iam", "aws-s3", "aws-lambda"],
    "responses": [
      {
        "agent": "aws-ec2",
        "question": "<サブエージェントに渡した質問>",
        "answer": "<サブエージェントからの回答>",
        "cli_commands": ["<CLIコマンド>"],
        "references": ["<参考URL>"]
      }
    ],
    "summary": "<全サブエージェントの回答を統合したサマリー>"
  }
}
```
