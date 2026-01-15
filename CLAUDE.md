# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## プロジェクト概要

エンターテイメント向けAIチャットボットWebアプリケーション。Next.js App Router + Hono APIサーバー + Mastra AIエージェントフレームワークで構成。

## 開発コマンド

```bash
# 初期セットアップ
make setup              # 依存関係インストール + Prismaクライアント生成

# 開発
make dev                # 開発サーバー起動 (localhost:3000)
make build              # 本番ビルド
make lint               # ESLint実行

# Docker
make docker-build       # Dockerイメージビルド
make docker-run         # ローカルでDockerコンテナ起動

# デプロイ
make deploy             # Cloud Runにデプロイ
```

## アーキテクチャ

```
フロントエンド (Next.js App Router)
    ↓ POST /api/chat (ストリーミング)
バックエンド (Hono on Next.js API Routes)
    ↓
Mastra Agent → Claude Sonnet 4 (Anthropic API)
```

### 主要コンポーネント

- **APIルート** (`src/app/api/[[...route]]/route.ts`): HonoをNext.js API Routesに統合。`/api/chat`（チャットエンドポイント）と`/api/health`（ヘルスチェック）を提供
- **AIエージェント** (`src/lib/mastra/agent.ts`): Mastra Agentの設定。Claude Sonnet 4を使用
- **チャットUI** (`src/components/Chat/`): React Client Componentsで構成。ストリーミングレスポンス対応
- **認証ミドルウェア** (`src/middleware.ts`): Next.js Middlewareで実装したBasic認証（`SKIP_BASIC_AUTH=true`でスキップ可能）

### データフロー

1. `ChatContainer.tsx`でユーザー入力を受け取り、会話履歴とともに`/api/chat`へPOST
2. HonoルートでMastra Agentにメッセージを渡し、ストリーミングレスポンスを開始
3. `streamText`でクライアントにリアルタイム配信
4. フロントエンドでReadableStreamを読み取り、UIを逐次更新

### 制約・制限

- メッセージ最大文字数: 4000文字
- 会話履歴の最大件数: 50件（API側）、100件（フロントエンド側）
- レート制限: 1分間に20リクエストまで
- APIタイムアウト: 60秒

## 環境変数

```env
ANTHROPIC_API_KEY=     # Anthropic APIキー（必須）
DATABASE_URL=          # MongoDB接続文字列（Prisma用）
SKIP_BASIC_AUTH=       # true で Basic認証をスキップ
BASIC_AUTH_USER=       # Basic認証ユーザー名（デフォルト: admin）
BASIC_AUTH_PASSWORD=   # Basic認証パスワード（デフォルト: password）
```

## 技術スタック

- **フロントエンド**: Next.js 16 (App Router), React 19, Tailwind CSS v4
- **バックエンド**: Hono 4, Prisma 7 (MongoDB)
- **AI**: Mastra Core, @ai-sdk/anthropic (Claude Sonnet 4)
