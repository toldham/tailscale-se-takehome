resource "google_compute_subnetwork" "network-with-private-secondary-ip-ranges" {
  name          = var.vpc_subnet_name
  ip_cidr_range = var.vpc_subnet_range
  region        = var.region
  network       = google_compute_network.custom-vpc-network.id
  secondary_ip_range {
    range_name    = "tf-test-secondary-range-update1"
    ip_cidr_range = "192.168.10.0/24"
  }
}

resource "google_compute_network" "custom-vpc-network" {
  project                 = var.project_id
  name                    = var.vpc_name
  auto_create_subnetworks = false
  mtu                     = 1460
}
