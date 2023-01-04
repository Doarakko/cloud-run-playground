# Cloud Run Playground

## Requirements

- GCP account
- gcloud command
- Terraform

## Usage

```sh
gcloud auth application-default login
```

```sh
terraform apply
```

## References

- [Workload Identityを使ってJSONキーなしでGitHubActionsからGCPにアクセスする(Terraform編)](https://qiita.com/shiozaki/items/2f61489c09ff196213b4)
- [How to push tagged Docker releases to Google Artifact Registry with a GitHub Action](https://gist.github.com/palewire/12c4b2b974ef735d22da7493cf7f4d37)

## Todo

- ar に登録したコンテナを cloud run にデプロイ
- cloud run job に job を登録
- Cloud Scheduler に上記 job を定期実行するように設定
- 差分があるときのみ github actions を実行する
