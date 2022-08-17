resource "google_sql_database_instance" "instance" {
  name             = var.db_name
  region           = var.region
  database_version = "MYSQL_8_0"
  settings {
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled = true
      private_network = google_compute_network.instance.id
    }
  }

  deletion_protection  = "false"
}

