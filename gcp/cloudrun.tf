
resource "google_cloud_run_service" "default" {
  name     = local.service_name
  location = local.region
  project  = local.project_id

  template {
    spec {
      containers {
        image = "${local.region}-docker.pkg.dev/${local.project_id}/${local.artifact_repo}/${local.image_name}:latest"

        env {
          name = "DB_USER"
          value_from {
            secret_key_ref {
              name = google_secret_manager_secret.db_user.secret_id
              key  = "latest"
            }
          }
        }
        env {
          name = "DB_PASSWORD"
          value_from {
            secret_key_ref {
              name = google_secret_manager_secret.db_password.secret_id
              key  = "latest"
            }
          }
        }

        resources {
          limits = {
            cpu    = "1"
            memory = "512Mi"
          }
        }
      }

      service_account_name = google_service_account.runtime.email
    }

    metadata {
      annotations = {
        "run.googleapis.com/vpc-access-connector" = google_vpc_access_connector.serverless_vpc.name
        "run.googleapis.com/vpc-access-egress"    = "all-traffic"
        "autoscaling.knative.dev/minScale"        = "0"
        "autoscaling.knative.dev/maxScale"        = "5"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  depends_on = [
    google_secret_manager_secret_version.db_user_version,
    google_secret_manager_secret_version.db_password_version,
    google_project_iam_member.secret_accessor,
    google_project_service.required_apis
  ]
}


# Allow unauthenticated access to Cloud Run Service
resource "google_cloud_run_service_iam_member" "no_auth" {
  location = local.region
  project  = local.project_id
  service  = google_cloud_run_service.default.name

  role   = "roles/run.invoker"
  member = "allUsers"
}


