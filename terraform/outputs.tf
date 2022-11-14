output "google_workload_identity_provider" {
  value = google_iam_workload_identity_pool_provider.github-actions.name
}
  
output "google_service_account" {
  value = google_service_account.github-actions.email
}
