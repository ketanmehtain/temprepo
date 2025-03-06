resource "google_compute_network" "vpc" {
  name                    = "${var.name_prefix}-vmmig"
  auto_create_subnetworks = false
  project                 = var.project_id

}

resource "google_compute_subnetwork" "subnet" {
  project       = var.project_id
  name          = "${var.name_prefix}-subnw"
  region        = "europe-west2"
  ip_cidr_range = "11.0.2.0/24"
  network       = google_compute_network.vpc.id
  depends_on = [google_compute_network.vpc]
}

resource "google_compute_firewall" "allow-rdp" {
  name    = "allow-rdp"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports = ["3389"]
  }

  source_ranges = ["0.0.0.0/0"]
  depends_on = [google_compute_network.vpc]
}

resource "google_compute_global_address" "private_vpc_ip" {
  name          = "${var.name_prefix}-private-ip"
  address_type  = "INTERNAL"
  purpose       = "VPC_PEERING"
  network       = google_compute_network.vpc.id
  prefix_length = 16
}

resource "google_service_networking_connection" "private_vpc_conn" {
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_vpc_ip.name]

  depends_on = [google_project_service.nw]
}