# Cloud Run アクセス制御（一時停止/再開）

## サービスへのパブリックアクセスをブロック（一時停止）

```bash
gcloud run services remove-iam-policy-binding mabl-aichat \
  --member="allUsers" \
  --role="roles/run.invoker" \
  --region=asia-northeast1 \
  --project=mabl-457308
```

**効果**: 認証なしではサービスにアクセスできなくなります。サービス自体は削除されず、設定も保持されます。

## パブリックアクセスを再開

```bash
gcloud run services add-iam-policy-binding mabl-aichat \
  --member="allUsers" \
  --role="roles/run.invoker" \
  --region=asia-northeast1 \
  --project=mabl-457308
```

**効果**: 誰でもサービスにアクセスできるようになります。

## 現在のアクセス設定を確認

```bash
gcloud run services get-iam-policy mabl-aichat \
  --region=asia-northeast1 \
  --project=mabl-457308
```

## 注意事項

- サービスは削除されないため、設定やイメージは保持されます
- `--min-instances=0` の設定なら、アクセスがなければ課金はほぼ発生しません
- 認証が必要な状態でも、適切な権限を持つユーザーはアクセス可能です
