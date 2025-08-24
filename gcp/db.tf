module "sql_db" {
  source  = "GoogleCloudPlatform/sql-db/google//modules/postgresql"
  version = "~> 22.0"

  project_id       = local.project_id
  region           = local.region
  name             = local.cloud_sql_instance_name
  database_version = "POSTGRES_15"

  tier            = local.db_tier
  disk_type       = "PD_SSD"
  disk_size       = 10
  disk_autoresize = true


  ip_configuration = {
    ipv4_enabled    = false
    private_network = module.vpc_network.network_self_link
    require_ssl     = true
  }


  user_name     = local.db_user
  user_password = random_password.db_password.result


  backup_configuration = {
    enabled = true
  }

  depends_on = [
    google_service_networking_connection.private_vpc_connection
  ]
}



resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = module.vpc_network.network_self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip.name]
}

resource "google_compute_global_address" "private_ip" {
  name          = "cloudsql-private-ip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = module.vpc_network.network_self_link
}
