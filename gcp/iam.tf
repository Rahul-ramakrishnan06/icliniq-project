#service accounts and role for cloudrun
resource "google_service_account" "runtime" {
  account_id   = "${local.service_name}-sa"
  display_name = "Service Account for ${local.service_name}"
  project      = local.project_id
}
resource "google_project_iam_member" "secret_accessor" {
  project = local.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.runtime.email}"
}

#service accounts and role for github actions
resource "google_artifact_registry_repository_iam_member" "github_actions_push" {
  project    = local.project_id
  location   = google_artifact_registry_repository.apps.location
  repository = google_artifact_registry_repository.apps.repository_id
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${values(module.github_actions_sa.emails)[0]}"
}

resource "google_storage_bucket_iam_member" "backend_bucket_access" {
  bucket = local.tf_state_bucket
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${values(module.github_actions_sa.emails)[0]}"
}

resource "google_project_iam_member" "github_actions_run_admin" {
  project = local.project_id
  role    = "roles/run.admin"
  member  = "serviceAccount:${values(module.github_actions_sa.emails)[0]}"
}

resource "google_service_account_iam_member" "allow_github_to_act_as_cloudrun_sa" {
  service_account_id = google_service_account.runtime.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${values(module.github_actions_sa.emails)[0]}"
}
