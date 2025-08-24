resource "google_compute_firewall" "allow_public_http" {
  name    = "${local.vpc_name}-allow-http"
  network = module.vpc_network.network_name

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
}