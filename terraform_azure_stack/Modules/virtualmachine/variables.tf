variable "resourcegroupname" {
  type    = string
  default = ""
}

variable "resourcegrouplocation" {
  type    = string
  default = ""
}

variable "public_ip_name" {
  type    = string
  default = ""
}

variable "network_interface_name" {
  type    = string
  default = ""
}

variable "virtual_machine_name" {
  type    = string
  default = ""
}

variable "admin_username" {
  type    = string
  default = ""
}

variable "admin_password" {
  type      = string
  sensitive = true
  default   = ""
}

variable "vm_size" {
  type    = string
  default = ""
}

variable "subnet_id" {
  type    = string
  default = ""
}