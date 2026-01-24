# 開発ガイドライン

このドキュメントは、mabl-aichatプロジェクトの開発における規約とベストプラクティスを定義します。

## 目次

1. [アーキテクチャ概要](#アーキテクチャ概要)
2. [ディレクトリ構造](#ディレクトリ構造)
3. [開発フロー](#開発フロー)
4. [コーディング規約](#コーディング規約)
5. [テスト戦略と実装指針](#テスト戦略と実装指針)
6. [data-testid規約](#data-testid規約)
7. [トラブルシューティング](#トラブルシューティング)
8. [参考リンク](#参考リンク)

---

## アーキテクチャ概要

### フロントエンド

```
Next.js 16 (App Router) + React 19 + TypeScript
```

- **状態管理**: React Hooks (useState, useCallback)
- **スタイリング**: Tailwind CSS v4
- **ストリーミング**: ReadableStream API

### バックエンド

```
Hono on Next.js API Routes
```

- **AIエージェント**: Mastra Core + @ai-sdk/anthropic (Claude Sonnet 4)
- **データベース**: Prisma + MongoDB
- **認証**: Basic認証 (Next.js Middleware)

### 通信フロー

```
[Browser] → [Next.js Dev Server (3000)]
              ↓
         [Hono API Routes (/api/*)]
              ↓
         [Mastra Agent] → [Anthropic API (Claude)]
              ↓
         [Streaming Response]
              ↓
         [Browser UI Update]
```

---

## ディレクトリ構造

```
src/
├── app/                          # Next.js App Router
│   ├── layout.tsx                # ルートレイアウト
│   ├── page.tsx                  # ホームページ
│   └── api/
│       └── [[...route]]/
│           └── route.ts          # Hono APIルート (/api/chat, /api/health)
├── components/                   # UIコンポーネント
│   ├── Chat/
│   │   ├── ChatContainer.tsx     # チャットコンテナ (状態管理・API通信)
│   │   ├── MessageList.tsx       # メッセージ一覧表示
│   │   ├── MessageInput.tsx      # メッセージ入力フォーム
│   │   ├── Message.tsx           # 個別メッセージ表示
│   │   ├── index.ts              # エクスポート集約
│   │   └── __tests__/            # コンポーネントテスト
│   └── Layout/
│       ├── Header.tsx            # ヘッダー
│       ├── index.ts              # エクスポート集約
│       └── __tests__/            # コンポーネントテスト
├── lib/                          # ライブラリ・サービス
│   ├── mastra/
│   │   ├── agent.ts              # Mastra AIエージェント設定
│   │   └── __tests__/            # エージェントテスト
│   └── prisma/
│       ├── client.ts             # Prismaクライアント
│       └── __tests__/            # データベーステスト
└── middleware.ts                 # Next.js Middleware (Basic認証)

prisma/
└── schema.prisma                 # Prismaスキーマ定義
```

---

## 開発フロー

### テスト駆動開発 (TDD)

このプロジェクトではTDDを採用しています。詳細は[テスト戦略と実装指針](#テスト戦略と実装指針)を参照。

```
1. Playwrightテストを書く (Red)
   ↓
2. テストが失敗することを確認
   ↓
3. 最小限の実装でテストを通す (Green)
   ↓
4. リファクタリング (Refactor)
   ↓
5. 繰り返し
   ↓
6. 機能完成後、必要に応じてmablでE2Eテストを作成
```

**重要**: 単体テストはPlaywright、E2Eテストはmablと役割を明確に分離する。

### ブランチ戦略

```
main          # 本番環境 (Cloud Runに自動デプロイ)
└── feature/* # 機能開発ブランチ
```

### コミットメッセージ

```
<type>: <subject>

# type:
#   feat     新機能
#   fix      バグ修正
#   refactor リファクタリング
#   test     テスト追加/修正
#   docs     ドキュメント
#   chore    ビルド/設定変更
```

### 開発コマンド

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

---

## コーディング規約

### TypeScript

```typescript
// 型は明示的に定義
type Props = {
  message: string
  onSend: (content: string) => void
}

// 関数コンポーネントはアロー関数または function 宣言
const MyComponent = ({ message, onSend }: Props) => {
  // ...
}

// Next.js App Router のコンポーネントは function 宣言も可
export default function Page() {
  // ...
}
```

### 定数

マジックナンバーはファイル上部にまとめて定義:

```typescript
// Good
const MAX_MESSAGE_LENGTH = 4000;
const MAX_HISTORY_LENGTH = 50;
const RATE_LIMIT_WINDOW_MS = 60 * 1000;

// Bad
if (message.length > 4000) { ... }
```

### コンポーネント設計

```typescript
// 1. "use client" ディレクティブ (必要な場合)
"use client";

// 2. インポート
import { useState, useCallback } from "react";
import { SomeComponent } from "./SomeComponent";

// 3. 定数定義
const MAX_VALUE = 100;

// 4. 型定義
type Props = {
  items: Item[];
  onSelect: (item: Item) => void;
}

// 5. コンポーネント本体
export function ItemList({ items, onSelect }: Props) {
  // 5a. 状態は上部にまとめる
  const [selected, setSelected] = useState<Item | null>(null);

  // 5b. ハンドラー関数はuseCallbackでメモ化
  const handleClick = useCallback((item: Item) => {
    setSelected(item);
    onSelect(item);
  }, [onSelect]);

  // 5c. JSXを返す
  return (
    <ul>
      {items.map(item => (
        <li key={item.id} onClick={() => handleClick(item)}>
          {item.name}
        </li>
      ))}
    </ul>
  );
}
```

### APIルート設計 (Hono)

```typescript
import { Hono } from "hono";
import { handle } from "hono/vercel";

const app = new Hono().basePath("/api");

// ミドルウェアはエンドポイント定義前に設定
app.use("/chat", limiter);

// エンドポイント定義
app.post("/chat", async (c) => {
  // 1. リクエストボディの取得と型付け
  const body = await c.req.json<ChatRequest>();

  // 2. バリデーション
  if (!body.message) {
    return c.json({ error: "メッセージが必要です" }, 400);
  }

  // 3. 処理とレスポンス
  return c.json({ result: "success" });
});

export const GET = handle(app);
export const POST = handle(app);
```

---

## テスト戦略と実装指針

プロジェクトの品質管理において、以下の役割分担を厳守すること。

### テストピラミッド

```
        ┌─────────┐
        │  E2E    │  ← mabl (ユーザーワークフロー)
        │ (mabl)  │
       ┌┴─────────┴┐
       │   単体     │  ← Playwright (モジュール単位)
       │(Playwright)│
      └─────────────┘
```

### 1. 単体テスト (Unit / Component Testing)

| 項目 | 内容 |
|------|------|
| **ツール** | Playwright |
| **格納場所** | 対象ソースファイルと同じディレクトリ内の `__tests__/` フォルダ |
| **命名規則** | `[ファイル名].spec.ts` または `[ファイル名].spec.tsx` |
| **レポート** | mabl Playwright Reporter (`@mablhq/playwright-reporter`) |

#### ファイル配置例

```
src/
├── components/
│   ├── Chat/
│   │   ├── ChatContainer.tsx
│   │   └── __tests__/
│   │       └── ChatContainer.spec.ts
├── lib/
│   ├── mastra/
│   │   ├── agent.ts
│   │   └── __tests__/
│   │       └── agent.spec.ts
```

#### 実装基準

- 各モジュールのロジック、関数、UIコンポーネントの単体動作を検証する
- 外部APIや副作用がある場合は、Playwrightの `route` や `mock` 機能を使用して隔離する
- 正常系・異常系・境界値を網羅する

#### テストの書き方

```typescript
import { test, expect } from '@playwright/test'

test.describe('ChatContainer Component', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/')
  })

  // 正常系
  test('should display message input', async ({ page }) => {
    await expect(page.getByTestId('message-input')).toBeVisible()
  })

  // 異常系
  test('should show error on empty message submit', async ({ page }) => {
    await page.getByTestId('btn-send').click()
    await expect(page.getByTestId('error-message')).toBeVisible()
  })

  // 外部APIのモック
  test('should handle API error gracefully', async ({ page }) => {
    await page.route('**/api/chat', route => {
      route.fulfill({ status: 500, body: JSON.stringify({ error: 'Server Error' }) })
    })
    await page.getByTestId('message-input').fill('テスト')
    await page.getByTestId('btn-send').click()
    await expect(page.getByTestId('error-message')).toBeVisible()
  })
})
```

#### テストコマンド

```bash
# テスト実行
npm run test

# UIモードで実行 (デバッグ向け)
npm run test:ui

# レポート表示
npm run test:report
```

### 2. E2Eテスト (End-to-End Testing)

| 項目 | 内容 |
|------|------|
| **ツール** | mabl |
| **管理場所** | mabl クラウド |
| **実行方法** | mabl CLI または mabl ダッシュボード |

#### 実装基準

- ユーザーの実際のワークフロー、画面遷移、統合的な動作を検証する
- ブラウザ上での複雑なアサーションや、複数画面にまたがるシナリオはmablで管理する
- Claude Codeは `mabl CLI` を活用し、必要に応じて既存テストの実行や新規テストの要件定義を行う

#### mabl CLIの使用例

```bash
# テスト一覧の取得
mabl tests list

# テストの実行
mabl tests run --id <test-id>

# デプロイメントイベントの送信
mabl deployments create --application-id <app-id> --environment-id <env-id>
```

#### Playwright vs mabl の使い分け

| 観点 | Playwright (単体テスト) | mabl (E2Eテスト) |
|------|------------------------|------------------|
| スコープ | 単一コンポーネント/関数 | ユーザーワークフロー全体 |
| 実行速度 | 高速 | 中速 |
| メンテナンス | 開発者がコードで管理 | QAチームがUIで管理 |
| 適用シナリオ | ロジック検証、回帰テスト | 統合テスト、クロスブラウザ |
| モック | 積極的に使用 | 実環境に近い状態で実行 |

### 3. テストの自律実行

コード修正・リファクタリング後は、以下のフローを**必ず**実行すること。

```
コード修正
    ↓
npm run test (Playwright単体テスト実行)
    ↓
  ┌─────────────────┐
  │ テスト結果確認   │
  └─────────────────┘
    ↓           ↓
  成功         失敗
    ↓           ↓
  完了      原因分析
              ↓
          コードまたは
          テストを修正
              ↓
          再実行 (ループ)
```

#### 自律実行のルール

1. **修正後は必ずテスト実行**: 関連するPlaywright単体テストを実行し、パスを確認
2. **失敗時は自律修正**: テスト失敗の原因を分析し、コードまたはテストを修正
3. **全テストパスまで継続**: すべてのテストがパスするまで修正を繰り返す
4. **mablテストへの影響確認**: `data-testid`を変更した場合はmablテストへの影響を報告

---

## data-testid規約

`data-testid`属性は**Playwright単体テスト**と**mabl E2Eテスト**の両方で使用されます。
既存の`data-testid`を変更すると両方のテストに影響するため、変更は慎重に行ってください。

### 変更時の影響範囲

| 変更内容 | Playwright | mabl |
|----------|------------|------|
| `data-testid`の追加 | テスト追加が必要 | テスト追加が必要 |
| `data-testid`の削除 | テスト修正が必要 | テスト修正が必要 |
| `data-testid`の変更 | テスト修正が必要 | テスト修正が必要 |

**重要**: `data-testid`を変更した場合は、Playwrightテストを修正した上で、mablテストへの影響も報告すること。

### 命名規則

```
btn-{action}        # ボタン: btn-send, btn-clear, btn-retry
input-{name}        # 入力: input-message, input-search
{component}-{item}  # コンポーネント内要素: message-list, message-item-{id}
error-{type}        # エラー表示: error-message, error-api
```

### 主要なdata-testid一覧

| カテゴリ | data-testid | 説明 |
|----------|-------------|------|
| チャット | `message-input` | メッセージ入力フィールド |
| チャット | `btn-send` | 送信ボタン |
| チャット | `message-list` | メッセージ一覧 |
| チャット | `message-item-{id}` | 個別メッセージ |
| チャット | `message-user` | ユーザーメッセージ |
| チャット | `message-assistant` | アシスタントメッセージ |
| エラー | `error-message` | エラーメッセージ表示 |
| エラー | `btn-dismiss-error` | エラー閉じるボタン |
| ヘッダー | `app-title` | アプリタイトル |
| ローディング | `loading-indicator` | 読み込み中表示 |

### 新規追加時の注意

```tsx
// Good: 一貫した命名
<button data-testid="btn-send">送信</button>
<input data-testid="message-input" />

// Bad: 不一致な命名
<button data-testid="sendButton">送信</button>
<button data-testid="send">送信</button>
```

---

## トラブルシューティング

### Playwrightテスト関連

**Q: Playwrightテストが失敗する**

```bash
# Playwrightブラウザを再インストール
npx playwright install

# キャッシュをクリア
rm -rf node_modules/.cache

# 特定のテストのみ実行してデバッグ
npm run test -- --grep "テスト名"

# UIモードでステップ実行
npm run test:ui
```

**Q: テストがタイムアウトする**

```bash
# タイムアウトを延長して実行
npm run test -- --timeout=60000

# 開発サーバーが起動しているか確認
curl http://localhost:3000
```

### mabl関連

**Q: mabl CLIが動作しない**

```bash
# mabl CLIのインストール確認
mabl --version

# 認証状態の確認
mabl auth status

# 再認証
mabl auth login
```

**Q: mablテストでdata-testidが見つからない**

1. Playwrightテストで同じ`data-testid`が動作するか確認
2. 要素が動的に生成される場合は、適切な待機処理を追加
3. `data-testid`が変更されていないか履歴を確認

### 開発環境関連

**Q: 型エラーが発生する**

```bash
# TypeScriptの型チェック
npx tsc --noEmit

# node_modulesを再インストール
rm -rf node_modules && npm install
```

**Q: 開発サーバーが起動しない**

```bash
# ポートが使用中か確認
lsof -i :3000

# プロセスを終了
kill -9 <PID>
```

**Q: Prismaクライアントエラー**

```bash
# Prismaクライアントを再生成
npx prisma generate

# データベース接続を確認
npx prisma db push
```

### API関連

**Q: チャットAPIが429エラーを返す**

- レート制限（1分間に20リクエスト）に達しています
- しばらく待ってから再度お試しください

**Q: チャットAPIが401エラーを返す**

- `ANTHROPIC_API_KEY`が設定されていないか無効です
- `.env`ファイルを確認してください

**Q: ストリーミングレスポンスが途切れる**

- APIタイムアウト（60秒）に達した可能性があります
- ネットワーク接続を確認してください

---

## 参考リンク

### 開発ツール

- [Next.js Documentation](https://nextjs.org/docs)
- [React Documentation](https://react.dev/)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)
- [Tailwind CSS v4](https://tailwindcss.com/)
- [Hono Documentation](https://hono.dev/)

### AI/ML

- [Mastra Documentation](https://mastra.ai/docs)
- [Anthropic API Documentation](https://docs.anthropic.com/)
- [AI SDK Documentation](https://sdk.vercel.ai/docs)

### データベース

- [Prisma Documentation](https://www.prisma.io/docs)
- [MongoDB Documentation](https://www.mongodb.com/docs/)

### テストツール

- [Playwright Documentation](https://playwright.dev/)
- [Playwright Test API](https://playwright.dev/docs/api/class-test)
- [mabl Documentation](https://help.mabl.com/)
- [mabl CLI Reference](https://help.mabl.com/docs/mabl-cli)
- [mabl Playwright Reporter](https://www.npmjs.com/package/@mablhq/playwright-reporter)
