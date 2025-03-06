# Define variables
variable "resource_group_name" {
  type    = string
  default = "Tmp-dharrogate-training-rg1"
}

variable "location" {
  type    = string
  default = "UK South"
}

variable "virtual_network_name" {
  type    = string
  default = "vmmig-vnet"
}

variable "subnet_name" {
  type    = string
  default = "vmmig-subnet"
}

variable "address_space" {
  type    = list(string)
  default = ["10.0.0.0/16"]
}

variable "subnet_prefix" {
  type    = string
  default = "10.0.1.0/24"
}

variable "public_ip_name" {
  type    = string
  default = "my-public-ip"
}

variable "network_interface_name" {
  type    = string
  default = "my-nic"
}

variable "virtual_machine_name" {
  type    = string
  default = "my-windows-vm"
}

variable "admin_username" {
  type    = string
  default = "azureuser"
}

variable "admin_password" {
  type      = string
  sensitive = true
  default   = "BlackP@ssword1968" # Change this!
}

variable "vm_size" {
  type    = string
  default = "Standard_D2ls_v5"
  # default = "Standard_DS1_v2"
}