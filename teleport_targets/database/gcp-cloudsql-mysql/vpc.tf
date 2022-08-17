resource "google_compute_network" "instance" {
  name = "${var.prefix}-teleport-target"
}

resource "google_compute_global_address" "private_ip_alloc" {
  name          = "private-ip-alloc"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 24
  network       = google_compute_network.instance.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.instance.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_alloc.name]
}