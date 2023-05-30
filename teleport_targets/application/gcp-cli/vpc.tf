resource "google_compute_network" "target-network" {
  name = "${var.prefix}-teleport-target"
}