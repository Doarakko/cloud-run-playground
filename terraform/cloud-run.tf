resource "google_cloud_run_service" "default" {
  name     = "fastapi"
  location = var.gcp_region

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
  location      = var.gcp_region
  repository_id = "playground"
  format        = "DOCKER"
}
