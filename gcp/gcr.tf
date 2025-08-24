resource "google_artifact_registry_repository" "apps" {
  location      = local.region
  repository_id = local.artifact_repo
  description   = "App images"
  format        = "DOCKER"
}


module "github_actions_sa" {
  source     = "terraform-google-modules/service-accounts/google"
  version    = "~> 4.0"
  project_id = local.project_id
  prefix     = local.service_account_prefix
  names      = ["github-actions"]

  project_roles = []

  generate_keys = true
}



