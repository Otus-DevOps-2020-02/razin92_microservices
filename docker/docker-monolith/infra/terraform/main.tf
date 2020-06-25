terraform {
  # Версия terraform
  required_version = "0.12.8"
}

provider "google" {
  # Версия провайдера
  version = "2.15.0"
  project = var.project
  region  = var.region
}

resource "google_compute_instance" "docker-host" {
  count        = var.counter
  name         = "docker-host-${count.index}"
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["docker-machine"]
  boot_disk {
    initialize_params {
      image = var.docker_disk_image
    }
  }
  network_interface {
    network = var.network_name
    access_config {}
  }
  metadata = {
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }
}

resource "google_compute_firewall" "firewall_puma" {
  name    = "allow-puma-default"
  network = var.network_name
  allow {
    protocol = "tcp"
    ports    = ["9292"]
  }
}
