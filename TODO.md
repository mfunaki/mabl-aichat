# mabl-aichat 実行計画

## フェーズ1: プロジェクト初期設定

- [x] Next.jsプロジェクトの作成（App Router + Tailwind CSS + TypeScript + ESLint）
  ```bash
  npx create-next-app@latest . --typescript --tailwind --eslint --app --src-dir
  ```
- [x] .gitignoreファイルの確認・追加設定
- [x] 環境変数ファイル（.env.local）の作成
  ```env
  ANTHROPIC_API_KEY=your_api_key
  DATABASE_URL=mongodb+srv://...
  ```
- [x] 追加パッケージのインストール
  ```bash
  # バックエンド関連
  npm install hono @hono/node-server

  # データベース関連
  npm install @prisma/client
  npm install -D prisma

  # AI関連
  npm install @mastra/core @ai-sdk/anthropic
  ```
- [x] ディレクトリ構成の作成

## フェーズ2: データベース設定

- [x] Prismaの初期化
  ```bash
  npx prisma init --datasource-provider mongodb
  ```
- [x] MongoDB接続設定（schema.prisma）
- [x] Prismaクライアントの生成
  ```bash
  npx prisma generate
  ```

## フェーズ3: バックエンド構築

- [x] Next.js App RouterへのHono統合（API Routes）
- [x] Mastraエージェントの設定（Claude Sonnet 4.5）
- [x] `/api/chat` エンドポイントの作成
- [x] ストリーミングレスポンスの実装

## フェーズ4: フロントエンド構築

- [x] レイアウトコンポーネントの作成（Header）
- [x] チャットコンテナコンポーネントの作成
- [x] メッセージ一覧コンポーネントの作成
- [x] メッセージ入力コンポーネントの作成
- [x] 個別メッセージコンポーネントの作成
- [x] セッション中の会話履歴管理（useState）
- [x] APIクライアントの実装
- [x] ストリーミング応答の表示処理

## フェーズ5: UI/UXの実装

- [x] グローバルスタイルの設定（Tailwind CSS）
- [x] ビジネスライクなデザインの適用
- [x] レスポンシブデザインの実装（PC・タブレット・スマホ）
- [x] ユーザー/AIメッセージの視覚的区別
- [x] ローディング状態の表示
- [x] エラーハンドリングUI

## フェーズ6: テスト・動作確認

- [x] ローカル環境での動作確認
- [x] チャット機能のテスト
- [x] ストリーミング応答のテスト
- [x] レスポンシブデザインの確認
- [x] エラーケースの確認

## フェーズ7: デプロイ準備

- [x] Dockerfileの作成
- [x] .dockerignoreの作成
- [x] 本番用環境変数の整理
- [x] ビルド・起動スクリプトの確認

## フェーズ8: Cloud Runへのデプロイ

- [ ] Google Cloud プロジェクトの設定
- [ ] Cloud Run用の設定（同時接続5〜10人想定）
- [ ] Dockerイメージのビルド・プッシュ
- [ ] Cloud Runへのデプロイ
- [ ] 環境変数の設定（Cloud Run管理画面）
  - ANTHROPIC_API_KEY
  - DATABASE_URL
  - NODE_ENV=production
- [ ] 本番環境での動作確認

## 補足: パッケージ一覧（参考）

### create-next-appで自動インストール
- next, react, react-dom
- typescript, @types/node, @types/react, @types/react-dom
- tailwindcss, postcss, autoprefixer
- eslint, eslint-config-next

### フェーズ1で追加インストール
- hono, @hono/node-server
- @prisma/client, prisma
- @mastra/core, @anthropic-ai/sdk
