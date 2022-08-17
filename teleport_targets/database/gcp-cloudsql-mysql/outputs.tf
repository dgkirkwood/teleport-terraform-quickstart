output "public-ip" {
  value = google_compute_instance.vm_instance.network_interface.0.access_config.0.nat_ip

}

output "sql_ip" {
  value = google_sql_database_instance.instance.public_ip_address
}

output "sql_CA" {
  value = google_sql_database_instance.instance.server_ca_cert.0.cert
}