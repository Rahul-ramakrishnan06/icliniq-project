locals {

  env = "icliniq-dev"

  region = "asia-south1"

  vpc_name = "icliniq-vpc"
  project_id = "icliniq-project"

  artifact_repo = "${local.project_id}-registry"

  service_name = "${local.project_id}-cloud-run"

  service_account_prefix = "${local.env}-"

  image_name = "icliniq-node-app"

  db_user = "admin"

  db_name = "icliniq-db"

  db_host = "10.0.0.0/16"

  cloud_sql_instance_name = "${local.env}-db"

  db_tier = "db-f1-micro"

  tf_state_bucket = "icliniq-state-bucket"

}