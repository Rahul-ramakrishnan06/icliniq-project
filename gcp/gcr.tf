resource "google_artifact_registry_repository" "apps" {
location = local.region
repository_id = local.artifact_repo
description = "App images"
format = "DOCKER"
}


module "github_actions_sa" {
  source        = "terraform-google-modules/service-accounts/google"
  version       = "~> 4.0"
  project_id    = local.project_id
  prefix        = local.service_account_prefix
  names         = ["github-actions"]
  
  project_roles = []
  
  generate_keys = true
}

resource "google_artifact_registry_repository_iam_member" "github_actions_push" {
  project    = local.project_id
  location   = google_artifact_registry_repository.apps.location
  repository = google_artifact_registry_repository.apps.repository_id
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${values(module.github_actions_sa.emails)[0]}"
}

resource "google_storage_bucket_iam_member" "backend_bucket_access" {
  bucket = local.tf_state_bucket
  role   = "roles/storage.objectAdmin"   # read/write/delete objects
  member = "serviceAccount:${values(module.github_actions_sa.emails)[0]}"
}

