terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.53.1"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = "asia-northeast1-a"
}

resource "google_project_service" "project" {
  project  = var.project_id
  for_each = toset(["iamcredentials.googleapis.com", "artifactregistry.googleapis.com", "run.googleapis.com", "secretmanager.googleapis.com"])
  service  = each.value
}

resource "google_service_account" "github-actions" {
  project      = var.project_id
  account_id   = "github-actions"
  display_name = "A service account for GitHub Actions"
}

resource "google_iam_workload_identity_pool" "github-actions" {
  provider                  = google-beta
  project                   = var.project_id
  workload_identity_pool_id = "gh-oidc-pool"
  display_name              = "gh-oidc-pool"
  description               = "Workload Identity Pool for GitHub Actions"
}

resource "google_iam_workload_identity_pool_provider" "github-actions" {
  provider                           = google-beta
  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github-actions.workload_identity_pool_id
  workload_identity_pool_provider_id = "gh-oidc-provider"
  display_name                       = "gh-oidc-provider"
  description                        = "OIDC identity pool provider for GitHub Actions"
  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repository"
  }
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

resource "google_service_account_iam_member" "admin-account-iam" {
  service_account_id = google_service_account.github-actions.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github-actions.name}/attribute.repository/${var.repo_name}"
}

resource "google_project_iam_member" "admin-account-iam" {
  project  = var.project_id
  for_each = toset(["roles/iam.serviceAccountUser", "roles/artifactregistry.admin", "roles/run.developer"])
  role     = each.value
  member   = "serviceAccount:${google_service_account.github-actions.email}"
}

resource "google_cloud_run_service" "default" {
  name     = "cloudrun-srv"
  location = var.region

  template {
    spec {
      containers {
        image = "us-docker.pkg.dev/cloudrun/container/hello"
        resources {
          limits = {
            "memory" = "128Mi"
          }
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  autogenerate_revision_name = true
}

resource "google_cloud_run_service_iam_binding" "default" {
  location = google_cloud_run_service.default.location
  service  = google_cloud_run_service.default.name
  role     = "roles/run.invoker"
  members = [
    "allUsers"
  ]
}

resource "google_artifact_registry_repository" "default" {
  location      = var.region
  repository_id = "playground"
  format        = "DOCKER"
}
