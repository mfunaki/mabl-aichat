# ベースイメージ
FROM node:20-alpine AS base

# 依存関係インストール用ステージ
FROM base AS deps
RUN apk add --no-cache libc6-compat
WORKDIR /app

# package.jsonとpackage-lock.jsonをコピー
COPY package.json package-lock.json* ./
COPY prisma ./prisma/

# 依存関係をインストール
RUN npm ci

# Prismaクライアントを生成
RUN npx prisma generate

# ビルド用ステージ
FROM base AS builder
WORKDIR /app

# 依存関係をコピー
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Next.jsのテレメトリを無効化
ENV NEXT_TELEMETRY_DISABLED=1

# アプリケーションをビルド
RUN npm run build

# 本番用ステージ
FROM base AS runner
WORKDIR /app

# 本番環境の設定
ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

# セキュリティ: 非rootユーザーを作成
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# 必要なファイルをコピー
COPY --from=builder /app/public ./public

# スタンドアロン出力を使用する場合のための設定
# Next.js 13以降のstandalone出力モードを使用
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

# Prismaクライアントをコピー
COPY --from=deps /app/node_modules/.prisma ./node_modules/.prisma
COPY --from=deps /app/node_modules/@prisma ./node_modules/@prisma

# 非rootユーザーに切り替え
USER nextjs

# ポートを公開
EXPOSE 3000

# 環境変数でポートを設定
ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

# アプリケーションを起動
CMD ["node", "server.js"]
