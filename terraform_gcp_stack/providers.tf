locals {
  tf_sa = var.service_account
}

# provider "google" {
#   impersonate_service_account = local.tf_sa
#   project                     = var.project_id
# }

provider "google" {
  project = "p-dev-lloyds-prep-ycm4-1"
  region  = "europe-west2"
}

provider "google-beta" {
  impersonate_service_account = local.tf_sa
  project                     = var.project_id

}

# provider "kubectl" {
#   host                   = module.gke_cluster.endpoint
#   cluster_ca_certificate = module.gke_cluster.ca_certificate
#   token                  = module.gke_cluster.token

#   alias = "gke"

# }

# provider "kubernetes" {
#   host                   = "https://${module.gke_cluster.endpoint}"
#   cluster_ca_certificate = base64decode(module.gke_cluster.ca_certificate)
#   token                  = module.gke_cluster.token

#   alias = "gke"
# }