# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }
  backend "azurerm" {
    resource_group_name  = "tf_rg_blobstore"
    storage_account_name = "tfstoragetonswart"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

variable "imagebuild" {
  type        = string
  description = "Latest Image Build"
}

variable "dockerhub_account" {
  type        = string
  description = "Docker Hub Account"
}

variable "dockerhub_repository" {
  type        = string
  description = "Docker Hub Repository"
}

resource "azurerm_resource_group" "tf_test" {
  name     = "tfmainrg"
  location = "West Europe"
}

resource "azurerm_container_group" "tfcg_test" {
  name                = "${var.dockerhub_repository}"
  location            = azurerm_resource_group.tf_test.location
  resource_group_name = azurerm_resource_group.tf_test.name

  ip_address_type = "Public"
  dns_name_label  = "${var.dockerhub_account}wa"
  os_type         = "Linux"

  container {
    name   = "weatherapi"
    image  = "${var.dockerhub_account}/${var.dockerhub_repository}:${var.imagebuild}"
    cpu    = 1
    memory = 1

    ports {
      port     = 80
      protocol = "TCP"
    }
  }
}
