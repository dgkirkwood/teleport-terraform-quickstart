data "google_compute_network" "proxy-network" {
  name = "${var.prefix}-teleport-proxy"
}