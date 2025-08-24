output "artifact_registry_url" {
  description = "Artifact Registry URL"
  value       = "${google_artifact_registry_repository.apps.location}-docker.pkg.dev/${local.project_id}/${google_artifact_registry_repository.apps.repository_id}"
}


output "service_account_email" {
  value = values(module.github_actions_sa.emails)[0]
}

output "service_account_key" {
  description = "Base64-encoded Service Account key for GitHub Actions"
  value       = values(module.github_actions_sa.keys)[0]
  sensitive   = true
}