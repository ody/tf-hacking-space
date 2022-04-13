terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.68.0"
    }
  }
}

# GCP region and project to operating within
provider "google" {
  project = var.project
  region  = var.region
}

locals {
  zones = ["us-west1-a","us-west1-b"]
}

resource "google_compute_instance" "server" {
  name         = "server-${count.index}"
  machine_type = "n1-standard-1"
  count        = var.server_count
  zone         = element(local.zones, count.index)

  # Constructing an FQDN from GCP convention for Zonal DNS and storing it as
  # metadata so it is a property of the instance, making it easy to use later in
  # Bolt
  metadata = {
    "ssh-keys"     = "${var.user}:${file(var.ssh_key)}"
    "VmDnsSetting" = "ZonalPreferred"
    "internalDNS"  = "server-${count.index}.${element(local.zones, count.index)}.c.${var.project}.internal"
  }

  labels = var.labels

  boot_disk {
    initialize_params {
      image = "almalinux-cloud/almalinux-8"
      size  = "20"
      type  = "pd-ssd"
    }
  }

  # Configuration of instances requires external IP address but it doesn't
  # matter what they are so dynamic sourcing them from global pool is ok
  # If a subnetwork_project is specified, an external IP is not needed.
  network_interface {
    network            = "default"
    subnetwork         = "default"
    dynamic "access_config" {
      for_each = var.server_public_ip ? [1] : []
      content {}
    }
  }
}

resource "google_compute_instance" "node" {
  name         = "node-${count.index}"
  machine_type = "n1-standard-1"
  # count is used to effectively "no-op" this resource in the event that we
  # deploy the standard architecture
  count = var.node_count
  zone  = element(local.zones, count.index)

  metadata = {
    "ssh-keys"     = "${var.user}:${file(var.ssh_key)}"
    "VmDnsSetting" = "ZonalPreferred"
    "internalDNS"  = "node-${count.index}.${element(local.zones, count.index)}.c.${var.project}.internal"
  }

  labels = var.labels

  boot_disk {
    initialize_params {
      image = "almalinux-cloud/almalinux-8"
      size  = "20"
      type  = "pd-ssd"
    }
  }

  # If a subnetwork_project is specified, an external IP is not needed.
  network_interface {
    network            = "default"
    subnetwork         = "default"
    dynamic "access_config" {
      for_each = var.node_public_ip ? [1] : []
      content {}
    }
  }
}
