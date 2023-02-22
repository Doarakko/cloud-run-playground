resource "google_cloud_run_v2_job" "default" {
  name         = "hello-world"
  location     = "asia-northeast1"
  launch_stage = "BETA"

  template {
    template {
      containers {
        image = "us-docker.pkg.dev/cloudrun/container/hello"
      }
    }
  }
}
