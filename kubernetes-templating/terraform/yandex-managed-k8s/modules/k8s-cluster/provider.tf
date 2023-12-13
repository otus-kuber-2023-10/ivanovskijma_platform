terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = ">= 0.13"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}

provider "yandex" {
  folder_id = var.folder_id
}

# provider "helm" {
#   kubernetes {
#     config_path = "~/.kube/config"
#   }
# }
# provider "kubectl" {
#   config_path    = "~/.kube/config"
# }