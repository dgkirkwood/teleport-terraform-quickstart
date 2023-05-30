data "google_compute_image" "teleport-target" {
  family = var.ami_name
}

resource "google_compute_instance" "vm_instance" {
  name         = "${var.prefix}-teleport-target"
  machine_type = "n1-standard-1"
  zone = "australia-southeast1-a"
  service_account {
    email = "dk-teleport-google-cloud-cli@weighty-planet-305123.iam.gserviceaccount.com"
    scopes = ["cloud-platform"]
  }

  boot_disk {
    initialize_params {
      image = data.google_compute_image.teleport-target.self_link
    }
  }

  network_interface {
    network = google_compute_network.target-network.name
    access_config {
    }
  }
  metadata_startup_script = <<EOF
#!/bin/bash
sudo hostnamectl set-hostname ${var.hostname}
echo ${var.jointoken} > /var/lib/teleport/jointoken
sudo systemctl restart teleport

EOF

}

