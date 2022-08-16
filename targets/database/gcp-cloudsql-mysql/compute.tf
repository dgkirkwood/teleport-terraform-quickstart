data "google_compute_image" "teleport-target" {
  family = var.ami_name
}

data "google_service_account" "sqladmin" {
  account_id = var.service_account_name
}

resource "google_compute_instance" "vm_instance" {
  name         = "${var.prefix}-teleport-target"
  machine_type = "n1-standard-1"

  boot_disk {
    initialize_params {
      image = data.google_compute_image.teleport-target.self_link
    }
  }
  network_interface {
    network = google_compute_network.instance.name
    access_config {
    }
  }
  service_account {
    email = data.google_service_account.sqladmin.email
    scopes = ["cloud-platform"]
  }
  metadata_startup_script = <<EOF
#!/bin/bash
sudo hostnamectl set-hostname ${var.host_name}
echo ${var.join_token} > /var/lib/teleport/jointoken
sudo tee -a /var/lib/teleport/server_ca_cert.pem <<'EOT'
${google_sql_database_instance.instance.server_ca_cert.0.cert}
EOT

sudo tee -a /etc/teleport.yaml <<'EOT'

db_service:
  enabled: "yes"
  databases:
  - name: ${var.db_name}
    description: "GCP Cloud SQL MySQL"
    protocol: "mysql"
    uri: ${google_sql_database_instance.instance.private_ip_address}:3306
    # Path to Cloud SQL instance root certificate you downloaded above.
    ca_cert_file: /var/lib/teleport/server_ca_cert.pem
    gcp:
      # GCP project ID.
      project_id: ${var.project_id}
      instance_id: ${var.db_name}
    # Labels to assign to the database, used in RBAC.
    static_labels:
      env: ${var.environment}
EOT
sudo systemctl restart teleport

EOF
  allow_stopping_for_update = true
}

