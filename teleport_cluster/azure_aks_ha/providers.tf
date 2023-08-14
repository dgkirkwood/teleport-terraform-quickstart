

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.68.0"
    }
    kubectl = {
      source = "gavinbunney/kubectl"
      version = "1.14.0"
    }
    time = {
      source = "hashicorp/time"
      version = "0.9.1"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "helm" {
  kubernetes {
    host                   = azurerm_kubernetes_cluster.teleport.kube_config.0.host
    client_certificate = base64decode(azurerm_kubernetes_cluster.teleport.kube_config.0.client_certificate)
    client_key = base64decode(azurerm_kubernetes_cluster.teleport.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.teleport.kube_config.0.cluster_ca_certificate)
  }
}

provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.teleport.kube_config.0.host
  client_certificate = base64decode(azurerm_kubernetes_cluster.teleport.kube_config.0.client_certificate)
  client_key = base64decode(azurerm_kubernetes_cluster.teleport.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.teleport.kube_config.0.cluster_ca_certificate)
}

provider "kubectl" {
  host                   = azurerm_kubernetes_cluster.teleport.kube_config.0.host
  client_certificate = base64decode(azurerm_kubernetes_cluster.teleport.kube_config.0.client_certificate)
  client_key = base64decode(azurerm_kubernetes_cluster.teleport.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.teleport.kube_config.0.cluster_ca_certificate)
}

data "azurerm_client_config" "current" {}
data "azurerm_subscription" "current" {}