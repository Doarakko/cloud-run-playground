# Cloud Run Playground

## Requirements

- Google Cloud account
- gcloud CLI
- Terraform

## Usage

```sh
gcloud auth application-default login
```

```sh
terraform apply
```

## References

- [Google Provider Configuration Reference: Authentication](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/provider_reference#authentication)
- [Workload Identityを使ってJSONキーなしでGitHubActionsからGCPにアクセスする(Terraform編)](https://qiita.com/shiozaki/items/2f61489c09ff196213b4)
- [How to push tagged Docker releases to Google Artifact Registry with a GitHub Action](https://gist.github.com/palewire/12c4b2b974ef735d22da7493cf7f4d37)
- [公開（未認証）アクセスを許可する](https://cloud.google.com/run/docs/authenticating/public)
