resource "google_project_service" "required_apis" {
  for_each = toset([
    "compute.googleapis.com",
    "run.googleapis.com",
    "sqladmin.googleapis.com",
    "vpcaccess.googleapis.com",
    "servicenetworking.googleapis.com",
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "secretmanager.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com",
    "serviceusage.googleapis.com",
    
  ])
  project = local.project_id
  service = each.key
}

module "vpc_network" {
  source  = "terraform-google-modules/network/google"
  version = "8.0.0" #

  project_id   = local.project_id
  network_name = local.vpc_name
  routing_mode = "REGIONAL"

  subnets = [
    {
      subnet_name           = "${local.vpc_name}-public"
      subnet_ip             = "10.0.1.0/24"
      subnet_region         = local.region
      subnet_private_access = "false"
      description           = "Public Subnet"
    },
    {
      subnet_name           = "${local.vpc_name}-private"
      subnet_ip             = "10.0.2.0/24"
      subnet_region         = local.region
      subnet_private_access = "true"
      description           = "Private Subnet for Cloud SQL"
    }
  ]

  secondary_ranges = {}

  depends_on = [google_project_service.required_apis]
}




resource "google_vpc_access_connector" "serverless_vpc" {
  name          = "${local.vpc_name}-vpc-connector"
  network       = module.vpc_network.network_name
  region        = local.region
  ip_cidr_range = "10.8.0.0/28" # Required /28 range for connector
}