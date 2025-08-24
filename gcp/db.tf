module "sql_db" {
  source  = "GoogleCloudPlatform/sql-db/google//modules/postgresql"
  version = "~> 22.0"

  project_id            = local.project_id
  region              = local.region
  name                = local.cloud_sql_instance_name   # e.g. "app-db"
  database_version    = "POSTGRES_15"

  tier                = local.db_tier          # e.g. "db-custom-1-3840"
  disk_type           = "PD_SSD"
  disk_size           = 10
  disk_autoresize     = true

  # Private IP configuration
  ip_configuration = {
    ipv4_enabled    = false
    private_network = module.vpc_network.network_self_link
    require_ssl     = true
  }

  # Credentials & user setup
  user_name             = local.db_user        
  user_password         = random_password.db_password.result

  # Enable automatic backups
  backup_configuration = {
    enabled = true
  }

  depends_on = [
    google_service_networking_connection.private_vpc_connection
  ]
}


# Create private service networking connection
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = module.vpc_network.network_self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip.name]
}

# Reserve a private IP range for Cloud SQL
resource "google_compute_global_address" "private_ip" {
  name          = "cloudsql-private-ip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = module.vpc_network.network_self_link
}
