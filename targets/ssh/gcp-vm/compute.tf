data "google_compute_image" "teleport-target" {
  family = "dk-teleport-ubuntu-target"
}

resource "google_compute_instance" "vm_instance" {
  name         = "${var.prefix}-teleport-target"
  machine_type = "n1-standard-1"
  zone = "australia-southeast1-a"

  boot_disk {
    initialize_params {
      image = data.google_compute_image.teleport-target.self_link
    }
  }

  network_interface {
    network = data.google_compute_network.proxy-network.name
    access_config {
    }
  }
}

