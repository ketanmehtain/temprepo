# GCP related variables

# SA variable 
variable "service_account" {
  description = "Service Account for impersonation"
  type        = string
  default     = "lloyds-gke-sa@p-dev-lloyds-prep-ycm4-1.iam.gserviceaccount.com"
}
variable "project_id" {
  description = "Project ID for GKE cluster to be deployed"
  type        = string
  default     = "p-dev-lloyds-prep-ycm4-1"
}
variable "region" {
  description = "Region for GKE cluster to be deployed"
  type        = string
  default     = "europe-west2"
}
# variable "name" {
#   description = "Name of the GKE cluster to be deployed"
#   type        = string
#   default     = "lloyds-gke"
# }
# variable "network" {
#   description = "Network for GKE cluster to use"
#   type        = string
#   default     = "shared-vpc-gke"
# }
# variable "subnetwork" {
#   description = "Subnetwork for GKE cluster to use"
#   type        = string
#   default     = "development"
# }
# variable "network_project_id" {
#   description = "Network project ID for GKE cluster to use"
#   type        = string
#   default     = "p-host-gke-7nss"
# }
# variable "ip_range_pods" {
#   description = "Pods IP range"
#   type        = string
#   default     = "pods"
# }
# variable "namespace" {
#   type        = string
#   default     = "boa"
#   description = "The namespace where the resources should be deployed"
# }
variable "email" {
  type        = string
  description = "The email that will have an admin access in both clusters"
  default     = "david.harrogate@endava.com"
}
variable "name_prefix" {
  type    = string
  default = "lloyds"
}
# variable "ip_range_services" {
#   description = "Services IP range"
#   type        = string
#   default     = "services"
# }
# variable "node_pools" {
#   description = "Node pools config"
#   type        = list(map(any))
#   default = [
#     {
#       name               = "default-node-pool"
#       machine_type       = "e2-standard-4"
#       min_count          = 1
#       max_count          = 4
#       local_ssd_count    = 0
#       disk_size_gb       = 100
#       disk_type          = "pd-ssd"
#       image_type         = "cos_containerd"
#       autoscaling        = false
#       auto_repair        = true
#       auto_upgrade       = true
#       preemptible        = false
#       initial_node_count = 1
#     },
#   ]
# }

# variable "container_name" {
#   type    = string
#   default = "dump"
# }

variable "sas_token" {
  type    = string
  default = ""
}

variable "storage_account" {
  type    = string
  default = ""
}