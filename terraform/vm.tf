resource "google_service_account" "custom-compute-sa" {
  account_id   = "tailscale-compute-sa"
  display_name = "Customer Service Account for VM Instance"
  project      = var.project_id
}

resource "google_compute_instance" "tailscale-subnet-router" {
  project      = var.project_id
  name         = var.vm_name
  machine_type = var.vm_machine_type
  zone         = var.zone
  hostname     = var.vm_hostname

  boot_disk {
    initialize_params {
      image = var.vm_image
      architecture = var.vm_architecture
    }
  }

  network_interface {
    network = google_compute_network.custom-vpc-network.id
    subnetwork  = google_compute_subnetwork.network-with-private-secondary-ip-ranges.id

    access_config {
      // Ephemeral public IP
    }
  }

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.custom-compute-sa.email
    scopes = ["cloud-platform"]
  }

}

resource "google_project_iam_member" "compute_admin_binding" {
  project = var.project_id
  role    = "roles/compute.instanceAdmin.v1"
  member  = "serviceAccount:${google_service_account.custom-compute-sa.email}"
}

