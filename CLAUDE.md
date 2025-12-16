# mabl-aichat

エンターテイメント向けAIチャットボットWebアプリケーション

## プロジェクト概要

- **プロジェクト名**: mabl-aichat
- **用途**: エンターテイメント向けチャットボット
- **対象ユーザー**: 一般ユーザー
- **デプロイ先**: Google Cloud Run

## 技術スタック

### フロントエンド
- **フレームワーク**: Next.js（App Router）
- **スタイリング**: Tailwind CSS
- **レスポンシブ対応**: 必須

### バックエンド
- **APIフレームワーク**: Hono
- **ORM**: Prisma
- **データベース**: MongoDB

### AI
- **AIエージェントフレームワーク**: Mastra
- **AIモデル**: Claude Sonnet 4（Anthropic）

## 機能要件

### チャット機能
- シンプルなテキストベースのチャット
- ユーザーがメッセージを送信し、AIが応答を返す
- ストリーミング応答: 対応（リアルタイム表示）

### 会話履歴
- セッション中のみ保持
- ページをリロードまたはタブを閉じるとリセット
- データベースへの永続化は不要

### ユーザー管理
- ログイン機能: なし
- 認証: 不要
- 誰でもすぐに利用可能

## UI/UX要件

### デザイン方向性
- ビジネスライクでクリーンなデザイン
- シンプルで使いやすいインターフェース

### レイアウト
- レスポンシブ対応（PC・タブレット・スマートフォン）
- ダークモード: 不要

### チャットUI
- メッセージ入力欄
- 送信ボタン
- 会話履歴表示エリア
- ユーザーとAIのメッセージを視覚的に区別

## アーキテクチャ

```
┌─────────────────────────────────────────────────────┐
│                    Frontend                          │
│                 Next.js (App Router)                 │
│                                                      │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  │
│  │  Chat UI    │  │   State     │  │   API       │  │
│  │  Component  │  │  Management │  │   Client    │  │
│  └─────────────┘  └─────────────┘  └─────────────┘  │
└─────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────┐
│                    Backend                           │
│                      Hono                            │
│                                                      │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  │
│  │   API       │  │   Mastra    │  │   Prisma    │  │
│  │   Routes    │  │   Agent     │  │   Client    │  │
│  └─────────────┘  └─────────────┘  └─────────────┘  │
└─────────────────────────────────────────────────────┘
                          │
              ┌───────────┴───────────┐
              ▼                       ▼
┌─────────────────────┐   ┌─────────────────────┐
│      Claude API     │   │      MongoDB        │
│     (Anthropic)     │   │                     │
└─────────────────────┘   └─────────────────────┘
```

## ディレクトリ構成（案）

```
mabl-aichat/
├── src/
│   ├── app/                    # Next.js App Router
│   │   ├── layout.tsx
│   │   ├── page.tsx
│   │   └── api/                # API Routes (Hono)
│   │       └── [[...route]]/
│   │           └── route.ts
│   ├── components/             # Reactコンポーネント
│   │   ├── Chat/
│   │   │   ├── ChatContainer.tsx
│   │   │   ├── MessageList.tsx
│   │   │   ├── MessageInput.tsx
│   │   │   └── Message.tsx
│   │   └── Layout/
│   │       └── Header.tsx
│   ├── lib/                    # ユーティリティ
│   │   ├── mastra/             # Mastra設定
│   │   │   └── agent.ts
│   │   └── prisma/             # Prisma設定
│   │       └── client.ts
│   └── styles/                 # スタイル
│       └── globals.css
├── prisma/
│   └── schema.prisma           # Prismaスキーマ
├── public/
├── package.json
├── tsconfig.json
├── next.config.js
├── Dockerfile                  # Cloud Run用
└── CLAUDE.md
```

## API設計

### POST /api/chat

チャットメッセージを送信し、AIの応答を取得する

**リクエスト**
```json
{
  "message": "ユーザーのメッセージ",
  "history": [
    { "role": "user", "content": "過去のメッセージ" },
    { "role": "assistant", "content": "過去の応答" }
  ]
}
```

**レスポンス**
```json
{
  "response": "AIの応答メッセージ"
}
```

## 環境変数

```env
# Anthropic API
ANTHROPIC_API_KEY=your_api_key

# MongoDB
DATABASE_URL=mongodb+srv://...

# その他
NODE_ENV=production
```

## デプロイ

### Google Cloud Run
- Dockerコンテナとしてデプロイ
- 環境変数はCloud Runの設定で管理
- 想定同時接続数: 5〜10人

## 開発コマンド（Makefile）

プロジェクトにはMakefileが用意されており、以下のコマンドで各種操作を実行できます。

### 初期化

```bash
make install          # 依存関係をインストール
make prisma-generate  # Prismaクライアントを生成
make setup            # 初期セットアップ (install + prisma-generate)
```

### 開発

```bash
make dev              # 開発サーバーを起動
make build            # 本番用ビルド
make start            # 本番サーバーを起動
make lint             # ESLintを実行
```

### Docker

```bash
make docker-build     # Dockerイメージをビルド
make docker-run       # Dockerコンテナを起動（ローカルテスト用）
```

### Cloud Run デプロイ

```bash
# デフォルト設定でデプロイ
make deploy

# プロジェクトIDとリージョンを指定してデプロイ
make deploy GCP_PROJECT=your-project-id GCP_REGION=asia-northeast1
```

デプロイ時の環境変数:
- `GCP_PROJECT`: Google Cloud プロジェクトID（必須）
- `GCP_REGION`: デプロイ先リージョン（デフォルト: asia-northeast1）
- `SERVICE_NAME`: Cloud Runサービス名（デフォルト: mabl-aichat）

**注意**: `ANTHROPIC_API_KEY`と`DATABASE_URL`はCloud Runコンソールで設定してください。

### その他

```bash
make clean            # ビルド成果物を削除
make health-check     # ヘルスチェックAPIを確認
make help             # 利用可能なコマンド一覧を表示
```

### npmコマンド（直接実行）

```bash
npm install           # 依存関係のインストール
npm run dev           # 開発サーバー起動
npm run build         # ビルド
npm start             # 本番サーバー起動
npx prisma generate   # Prismaクライアント生成
```

## 今後の拡張可能性（参考）

- 会話履歴の永続化
- ユーザー認証機能
- キャラクター選択機能
- ストリーミング応答
- ダークモード対応
