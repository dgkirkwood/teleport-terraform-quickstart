# Note these are not required if the proxy has been provisioned already as it has created the firewall rules as well.

resource "google_compute_firewall" "proxy" {
  network = google_compute_network.instance.name
  name = "${var.prefix}-teleport-target-access"
  direction = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "tcp"
    ports = ["22","443"]
  }

}

resource "google_compute_firewall" "proxy-egress" {
  network = google_compute_network.instance.name
  name = "${var.prefix}-teleport-target-egress"
  direction = "EGRESS"
  allow {
    protocol = "all"
  }

}