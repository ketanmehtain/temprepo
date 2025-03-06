variable "resourcegroupname" {
  type    = string
  default = ""
}

variable "resourcegrouplocation" {
  type    = string
  default = ""
}

variable "name" {
  type    = string
  default = ""
}

variable "virtual_network_name" {
  type    = string
  default = ""
}

variable "subnet_name" {
  type    = string
  default = ""
}

variable "address_space" {
  type    = list(string)
  default = [""]
}

variable "subnet_prefix" {
  type    = string
  default = ""
}

variable "addressprefixes" {
  type    = list(string)
  default = [""]
}