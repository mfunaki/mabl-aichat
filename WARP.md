# WARP.md

Warp Terminal向けのプロジェクトガイド。開発効率を最大化するためのクイックリファレンス。

---

## 1. Project Overview

**プロジェクト名**: mabl-aichat
**目的**: エンターテイメント向けAIチャットボットWebアプリケーション

### 技術スタック

| レイヤー | 技術 | バージョン |
|---------|------|-----------|
| フロントエンド | Next.js (App Router) | 16.x |
| UI | React + Tailwind CSS | 19.x / v4 |
| バックエンド | Hono (on Next.js API Routes) | 4.x |
| AI | Mastra Core + Claude Sonnet 4 | - |
| DB | Prisma + MongoDB | 7.x |
| インフラ | Docker + Cloud Run | - |

---

## 2. Quick Start

```bash
# 初期セットアップ
make setup

# 開発サーバー起動 (localhost:3000)
make dev

# ビルド
make build

# Lint
make lint

# ヘルスチェック
make health-check
```

### Docker

```bash
# イメージビルド
make docker-build

# コンテナ起動
make docker-run

# docker-compose で起動
docker compose up -d
```

---

## 3. Key Directories

```
src/
├── app/
│   ├── api/[[...route]]/route.ts  # Hono API (チャット/ヘルスチェック)
│   ├── layout.tsx                  # ルートレイアウト
│   └── page.tsx                    # メインページ
├── components/
│   ├── Chat/                       # チャットUI (Container, Message, Input, List)
│   └── Layout/                     # ヘッダー等
├── lib/
│   ├── mastra/agent.ts             # Mastra AI Agent設定
│   └── prisma/client.ts            # Prismaクライアント
├── generated/prisma/               # Prisma生成ファイル
└── middleware.ts                   # Basic認証ミドルウェア

prisma/
└── schema.prisma                   # DBスキーマ定義
```

---

## 4. Environment & Tools

### 環境変数 (.env.local)

```env
ANTHROPIC_API_KEY=sk-ant-xxx       # 必須: Anthropic APIキー
DATABASE_URL=mongodb+srv://...      # Prisma用MongoDB接続文字列
SKIP_BASIC_AUTH=true                # 開発時: Basic認証スキップ
BASIC_AUTH_USER=admin               # Basic認証ユーザー
BASIC_AUTH_PASSWORD=password        # Basic認証パスワード
```

### Docker

```bash
# ローカルでDockerコンテナをテスト
docker build -t mabl-aichat:latest .
docker run -p 3000:3000 \
  -e ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY \
  -e DATABASE_URL=$DATABASE_URL \
  mabl-aichat:latest

# docker-compose
docker compose up -d
docker compose logs -f app
docker compose down
```

### Cloud Run デプロイ

```bash
# .envにGCP設定を追加
# PROJECT_ID=your-gcp-project-id
# GCP_REGION=asia-northeast1

make deploy
```

---

## 5. Warp Workflows

Warpの「Workflows」に登録すると便利なコマンド集。

### 開発系

```yaml
# ワークフロー名: dev-start
name: 開発サーバー起動
command: make dev
```

```yaml
# ワークフロー名: dev-full-restart
name: クリーンビルド後に開発サーバー起動
command: make clean && make setup && make dev
```

```yaml
# ワークフロー名: lint-fix
name: ESLint実行
command: npm run lint
```

### Docker系

```yaml
# ワークフロー名: docker-rebuild
name: Dockerイメージ再ビルド＆起動
command: docker compose down && docker compose build --no-cache && docker compose up -d
```

```yaml
# ワークフロー名: docker-logs
name: Dockerログ表示
command: docker compose logs -f app
```

### デバッグ系

```yaml
# ワークフロー名: health
name: APIヘルスチェック
command: curl -s http://localhost:3000/api/health | jq .
```

```yaml
# ワークフロー名: chat-test
name: チャットAPIテスト
command: |
  curl -X POST http://localhost:3000/api/chat \
    -H "Content-Type: application/json" \
    -d '{"messages":[{"role":"user","content":"こんにちは"}]}'
```

### Prisma系

```yaml
# ワークフロー名: prisma-studio
name: Prisma Studio起動
command: npx prisma studio
```

```yaml
# ワークフロー名: prisma-gen
name: Prismaクライアント再生成
command: npx prisma generate
```

---

## 6. MCP Integration

このプロジェクトで活用すべきMCPサーバーのリスト。

### 推奨MCPサーバー

| MCP Server | 用途 | 設定例 |
|------------|------|--------|
| **GitHub** | PR作成、Issue管理、コードレビュー | `gh` CLI連携 |
| **Docker** | コンテナ管理、ログ確認 | `docker compose` 操作 |
| **MongoDB** | データ確認、クエリ実行 | Prisma Studio経由または直接接続 |
| **Filesystem** | プロジェクトファイル操作 | 読み書き権限設定 |

### MCP設定例 (claude_desktop_config.json)

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/path/to/mabl-aichat"]
    },
    "github": {
      "command": "gh",
      "args": ["mcp"]
    }
  }
}
```

### Warp AI統合

Warp AIと組み合わせて使用する際のTips:

- `#` でAIに質問: `# このプロジェクトのビルドコマンドは？`
- `Ctrl+Shift+R` でワークフロー呼び出し
- コマンド履歴から学習させてカスタムワークフロー作成

---

## クイックリファレンス

| タスク | コマンド |
|--------|---------|
| セットアップ | `make setup` |
| 開発サーバー | `make dev` |
| ビルド | `make build` |
| Lint | `make lint` |
| Dockerビルド | `make docker-build` |
| Docker起動 | `make docker-run` |
| デプロイ | `make deploy` |
| クリーン | `make clean` |
| ヘルスチェック | `make health-check` |
