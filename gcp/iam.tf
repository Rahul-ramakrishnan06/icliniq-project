# resource "google_service_account" "cloud_run_sa" {
#   account_id   = "cloud-run-deployer"
#   display_name = "Cloud Run Service Account"
# }

# resource "google_project_iam_member" "cloud_run_permissions" {
#   for_each = toset([
#     "roles/run.admin",
#     "roles/iam.serviceAccountUser",
#     "roles/secretmanager.secretAccessor",
#     "roles/cloudsql.client"
#   ])
#   project = var.project_id
#   member  = "serviceAccount:${google_service_account.cloud_run_sa.email}"
#   role    = each.value
# }