.PHONY: help install dev build start clean prisma-generate docker-build docker-run deploy health-check

# デフォルトターゲット
help:
	@echo "mabl-aichat - 利用可能なコマンド:"
	@echo ""
	@echo "  初期化:"
	@echo "    make install        - 依存関係をインストール"
	@echo "    make prisma-generate - Prismaクライアントを生成"
	@echo "    make setup          - 初期セットアップ (install + prisma-generate)"
	@echo ""
	@echo "  開発:"
	@echo "    make dev            - 開発サーバーを起動"
	@echo "    make build          - 本番用ビルド"
	@echo "    make start          - 本番サーバーを起動"
	@echo "    make lint           - ESLintを実行"
	@echo ""
	@echo "  Docker:"
	@echo "    make docker-build   - Dockerイメージをビルド"
	@echo "    make docker-run     - Dockerコンテナを起動"
	@echo ""
	@echo "  Cloud Run:"
	@echo "    make deploy         - Cloud Runにデプロイ"
	@echo ""
	@echo "  その他:"
	@echo "    make clean          - ビルド成果物を削除"
	@echo "    make health-check   - ヘルスチェックAPIを確認"

# =============================================================================
# 初期化
# =============================================================================

# 依存関係のインストール
install:
	npm install

# Prismaクライアントの生成
prisma-generate:
	npx prisma generate

# 初期セットアップ
setup: install prisma-generate
	@echo "セットアップが完了しました"

# =============================================================================
# 開発
# =============================================================================

# 開発サーバーの起動
dev:
	npm run dev

# 本番用ビルド
build:
	npm run build

# 本番サーバーの起動
start:
	npm start

# ESLintの実行
lint:
	npm run lint

# =============================================================================
# Docker
# =============================================================================

# Dockerイメージ名
IMAGE_NAME := mabl-aichat
IMAGE_TAG := latest

# Dockerイメージのビルド
docker-build:
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) .

# Dockerコンテナの起動（ローカルテスト用）
docker-run:
	docker run -p 3000:3000 \
		-e ANTHROPIC_API_KEY=$(ANTHROPIC_API_KEY) \
		-e DATABASE_URL=$(DATABASE_URL) \
		-e NODE_ENV=production \
		$(IMAGE_NAME):$(IMAGE_TAG)

# =============================================================================
# Cloud Run デプロイ
# =============================================================================

# Google Cloud プロジェクトID（環境変数で指定）
GCP_PROJECT ?= your-gcp-project-id
GCP_REGION ?= asia-northeast1
SERVICE_NAME ?= mabl-aichat

# Cloud Runにデプロイ
deploy: docker-build
	@echo "Cloud Runにデプロイ中..."
	gcloud builds submit --tag gcr.io/$(GCP_PROJECT)/$(IMAGE_NAME)
	gcloud run deploy $(SERVICE_NAME) \
		--image gcr.io/$(GCP_PROJECT)/$(IMAGE_NAME) \
		--platform managed \
		--region $(GCP_REGION) \
		--allow-unauthenticated \
		--min-instances 0 \
		--max-instances 10 \
		--memory 512Mi \
		--cpu 1 \
		--concurrency 80 \
		--set-env-vars NODE_ENV=production
	@echo "デプロイが完了しました"
	@echo "注意: ANTHROPIC_API_KEYとDATABASE_URLはCloud Runコンソールで設定してください"

# =============================================================================
# その他
# =============================================================================

# ビルド成果物の削除
clean:
	rm -rf .next
	rm -rf node_modules/.cache
	@echo "ビルド成果物を削除しました"

# ヘルスチェック
health-check:
	@curl -s http://localhost:3000/api/health | jq . || echo "サーバーが起動していないか、jqがインストールされていません"
