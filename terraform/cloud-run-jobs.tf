resource "google_cloud_run_v2_job" "default" {
  name         = "hello-world"
  location     = var.gcp_region
  launch_stage = "BETA"

  template {
    template {
      volumes {
        name = "a-volume"
        secret {
          secret       = google_secret_manager_secret.name.secret_id
          default_mode = 292
          items {
            version = "1"
            path    = "my-secret"
            mode    = 256
          }
        }
      }
      containers {
        image = "us-docker.pkg.dev/cloudrun/container/hello"
        volume_mounts {
          name       = "a-volume"
          mount_path = "/secrets"
        }
        env {
          name  = "PROJECT_ID"
          value = var.gcp_project_id
        }
      }
    }
  }
}

resource "google_secret_manager_secret" "name" {
  secret_id = "name"

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "default" {
  secret      = google_secret_manager_secret.name.name
  secret_data = "please enter in console"
}

resource "google_secret_manager_secret_iam_member" "default" {
  secret_id  = google_secret_manager_secret.name.id
  role       = "roles/secretmanager.secretAccessor"
  member     = "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"
  depends_on = [google_secret_manager_secret.name]
}

resource "google_cloud_scheduler_job" "default" {
  name             = "hello-world-job"
  schedule         = "50 * * * *"
  time_zone        = "Asia/Tokyo"
  attempt_deadline = "15s"
  region           = var.gcp_region

  retry_config {
    retry_count = 0
  }

  http_target {
    http_method = "POST"
    uri         = "https://${var.gcp_region}-run.googleapis.com/apis/run.googleapis.com/v1/namespaces/${var.gcp_project_id}/jobs/hello-world:run"

    oauth_token {
      service_account_email = "${data.google_project.project.number}-compute@developer.gserviceaccount.com"
    }
  }
}
