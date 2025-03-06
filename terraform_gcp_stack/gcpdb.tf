resource "google_project_service" "db" {
  project            = var.project_id
  service            = "sqladmin.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "nw" {
  project = var.project_id
  service = "servicenetworking.googleapis.com"
}

resource "google_sql_database_instance" "this" {
  name                = "vmmig-db01"
  database_version    = "POSTGRES_16"
  region              = var.region
  deletion_protection = false

  settings {
    tier = "db-f1-micro"
    edition = "ENTERPRISE"
    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = google_compute_network.vpc.self_link
      enable_private_path_for_google_cloud_services = true
      psc_config {
        psc_enabled = true
        allowed_consumer_projects = ["${var.project_id}"]
      }
      authorized_networks {
        name = "vmmig_subnet"
        value = google_compute_subnetwork.subnet.ip_cidr_range
      }
    }

    database_flags {
      name  = "max_connections"
      value = "50"
    }
  }

  depends_on = [google_service_networking_connection.private_vpc_conn]
}

resource "google_sql_user" "users" {
  name     = "psqladmin"
  instance = google_sql_database_instance.this.name
  password = "psqladmin"
}

resource "google_sql_database" "accounts" {
  name       = "accounts-db"
  instance   = google_sql_database_instance.this.name
  depends_on = [google_sql_user.users]
}

resource "google_sql_database" "ledger" {
  name       = "ledger-db"
  instance   = google_sql_database_instance.this.name
  depends_on = [google_sql_user.users]
}