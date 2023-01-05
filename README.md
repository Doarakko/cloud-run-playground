# Cloud Run Playground

Deploy original Docker image to Cloud Run using Terraform and GitHub Actions.
It uses Workload Identity for authentication with Github Actions.

## Requirements

- Google Cloud account
- gcloud CLI
- Terraform

## Usage

### 1. Fork this repository

### 2. Create your Google Cloud project

### 3. Enter your GitHub repository and Google Cloud project name to `terraform/variables.tf`

```hcl
variable "project_id" {
  default = "<Google Cloud project id>"
}

variable "repo_name" {
  default = "GitHub reposisotry name"
}
```

### 4. Authenticate to Google Cloud from CLI

```sh
gcloud auth application-default login
```

### 5. Get `service_account` and `workload_identity_provider`

```sh
terraform apply
```

```sh
...
Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

Outputs:

google_service_account = "<Google service account>"
google_workload_identity_provider = "<Google workload identity provider>"
```

### 6. Edit `.github/workflows/deploy.yml`

```yml
...
      - id: 'auth'
        uses: 'google-github-actions/auth@v0'
        with:
          token_format: 'access_token'
          workload_identity_provider: '<Google workload identity provider>'
          service_account: '<Google service account>'
...
      - name: Build and push
        uses: docker/build-push-action@v3
        with:
          context: "{{defaultContext}}:app"
          push: true
          tags: asia-northeast1-docker.pkg.dev/<Google Cloud project id>/playground/fastapi:latest
      - id: 'deploy'
        uses: 'google-github-actions/deploy-cloudrun@v1'
        with:
          region: 'asia-northeast1'
          service: 'cloudrun-srv'
          image: 'asia-northeast1-docker.pkg.dev/<<Google Cloud project id>>/playground/fastapi'

```

### 7. Commit and push to your repository

### 8. Go

![](./example.png)

## References

- [Google Provider Configuration Reference: Authentication](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/provider_reference#authentication)
- [Workload Identityを使ってJSONキーなしでGitHubActionsからGCPにアクセスする(Terraform編)](https://qiita.com/shiozaki/items/2f61489c09ff196213b4)
- [How to push tagged Docker releases to Google Artifact Registry with a GitHub Action](https://gist.github.com/palewire/12c4b2b974ef735d22da7493cf7f4d37)
- [公開（未認証）アクセスを許可する](https://cloud.google.com/run/docs/authenticating/public)
