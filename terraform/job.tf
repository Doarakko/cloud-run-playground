resource "google_cloud_run_v2_job" "default" {
  name         = "hello-world"
  location     = var.region
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
          value = var.project_id
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

resource "google_secret_manager_secret_version" "secret-version-data" {
  secret      = google_secret_manager_secret.name.name
  secret_data = "please enter in console"
}

resource "google_secret_manager_secret_iam_member" "secret-access" {
  secret_id  = google_secret_manager_secret.name.id
  role       = "roles/secretmanager.secretAccessor"
  member     = "serviceAccount:${var.project_number}-compute@developer.gserviceaccount.com"
  depends_on = [google_secret_manager_secret.name]
}

resource "google_cloud_scheduler_job" "job" {
  name             = "hello-world-job"
  schedule         = "50 * * * *"
  time_zone        = "Asia/Tokyo"
  attempt_deadline = "15s"
  region           = var.region

  retry_config {
    retry_count = 0
  }

  http_target {
    http_method = "POST"
    uri         = "https://${var.region}-run.googleapis.com/apis/run.googleapis.com/v1/namespaces/${var.project_id}/jobs/hello-world:run"

    oauth_token {
      service_account_email = "${var.project_number}-compute@developer.gserviceaccount.com"
    }
  }
}
