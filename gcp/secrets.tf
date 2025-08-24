# DB User Secret
resource "google_secret_manager_secret" "db_user" {
  project   = local.project_id
  secret_id = "DB_USER"

  replication {
    auto {}
  }
}

# DB User Secret Value
resource "google_secret_manager_secret_version" "db_user_version" {
  secret      = google_secret_manager_secret.db_user.id
  secret_data = local.db_user
}

resource "random_password" "db_password" {
  length           = 16   # Password length
  special          = true # Include special chars
  upper            = true
  lower            = true
  numeric          = true
  override_special = "_%@!" # Safe special chars for DBs
}

# DB Password Secret
resource "google_secret_manager_secret" "db_password" {
  project   = local.project_id
  secret_id = "DB_PASSWORD"

  replication {
    auto {
    }
  }
}

resource "google_secret_manager_secret_version" "db_password_version" {
  secret      = google_secret_manager_secret.db_password.id
  secret_data = random_password.db_password.result
}
