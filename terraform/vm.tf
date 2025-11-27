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

  metadata_startup_script = <<-EOF
    #!/bin/bash
    sudo firewall-cmd --permanent --add-masquerade
    sudo firewall-cmd --reload
    echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
    echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
    sudo sysctl -p /etc/sysctl.d/99-tailscale.conf
    curl -fsSL https://tailscale.com/install.sh | sh && sudo tailscale up --auth-key=${var.vm_tailscale_api_auth}
    sudo tailscale set --advertise-routes=${var.vpc_subnet_range}
    EOF
    
  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.custom-compute-sa.email
    scopes = ["cloud-platform"]
  }

}

resource "google_compute_instance" "tailscale-ssh" {
  project      = var.project_id
  name         = var.vm_name_ssh
  machine_type = var.vm_machine_type
  zone         = var.zone
  hostname     = var.vm_hostname_ssh

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

  metadata_startup_script = <<-EOF
    #!/bin/bash
    curl -fsSL https://tailscale.com/install.sh | sh && sudo tailscale up --auth-key=${var.vm_tailscale_api_auth}
    sudo tailscale set --ssh
    EOF
    
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

