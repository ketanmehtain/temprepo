terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  required_version = ">= 0.14.9"
}

provider "azurerm" {
  features {}
  subscription_id = "543f5997-dfc3-4e03-91a6-cfed72cb620c"
  tenant_id = "76f52bad-3b8b-4920-b06f-39bc0e67ee30"
}