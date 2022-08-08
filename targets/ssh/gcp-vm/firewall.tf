resource "google_compute_firewall" "proxy" {
  network = data.google_compute_network.proxy-network.name
  name = "${var.prefix}-teleport-target-access"
  direction = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "tcp"
    ports = ["22","443"]
  }

}

resource "google_compute_firewall" "proxy-egress" {
  network = data.google_compute_network.proxy-network.name
  name = "${var.prefix}-teleport-target-egress"
  direction = "EGRESS"
  allow {
    protocol = "all"
  }

}

