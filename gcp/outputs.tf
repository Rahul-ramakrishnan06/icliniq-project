# output "vpc_name" {
#   description = "VPC Network Name"
#   value       = module.vpc_network.network_name
# }

# output "private_subnet" {
#   description = "Private Subnet"
#   value       = module.vpc_network.subnets_self_links[1]
# }

# output "cloud_sql_private_ip" {
#   description = "Cloud SQL Private IP"
#   value       = google_sql_database_instance.db_instance.private_ip_address
# }

# output "serverless_vpc_connector" {
#   description = "Serverless VPC Access Connector Name"
#   value       = google_vpc_access_connector.serverless_vpc.name
# }

# output "cloud_run_service_account" {
#   description = "Cloud Run Service Account Email"
#   value       = google_service_account.cloud_run_sa.email
# }



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