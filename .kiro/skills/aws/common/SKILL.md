---
name: aws-json-format
description: 【必須】AWS質問への応答時に使用するJSON形式。応答、回答、返答、answer、response、json、フォーマット、形式を含む全ての応答で参照すること。
---

# JSON応答フォーマット

## サブエージェント応答

```json
{
  "agent": "<agent-name>",
  "question": "<受け取った質問>",
  "answer": "<詳細な回答>",
  "cli_commands": ["<関連CLIコマンド>"],
  "references": ["<参考ドキュメント>"]
}
```

## aws-qa統合応答

```json
{
  "aws_qa_response": {
    "original_question": "<元の質問>",
    "services_consulted": ["<参照したエージェント>"],
    "responses": [<各サブエージェントのJSON>],
    "summary": "<統合サマリー>"
  }
}
```
