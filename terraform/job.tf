resource "google_cloud_run_v2_job" "default" {
  name         = "hello-world"
  location     = var.region
  launch_stage = "BETA"

  template {
    template {
      volumes {
        name = "a-volume"
        secret {
          secret       = google_secret_manager_secret.secret.secret_id
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
          name = "PROJECT_ID"
          value = var.project_id
        }
      }
    }
  }
}

resource "google_secret_manager_secret" "secret" {
  secret_id = "name"

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "secret-version-data" {
  secret      = google_secret_manager_secret.secret.name
  secret_data = "please enter in console"
}

resource "google_secret_manager_secret_iam_member" "secret-access" {
  secret_id  = google_secret_manager_secret.secret.id
  role       = "roles/secretmanager.secretAccessor"
  member     = "serviceAccount:${var.project_number}-compute@developer.gserviceaccount.com"
  depends_on = [google_secret_manager_secret.secret]
}