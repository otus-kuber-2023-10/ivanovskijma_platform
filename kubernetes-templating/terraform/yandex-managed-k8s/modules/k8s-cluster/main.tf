
resource "yandex_vpc_network" "k8snetwork" {
  name = "k8snetwork"
}

resource "yandex_vpc_subnet" "k8ssubnet" {
  v4_cidr_blocks = ["10.10.0.0/16"]
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.k8snetwork.id
}

resource "yandex_iam_service_account" "k8saccount" {
  name        = var.sa_name
  description = "K8S zonal service account"
}

resource "yandex_resourcemanager_folder_iam_binding" "admin" {
  folder_id = var.folder_id
  role      = "admin"
  members = [
    "serviceAccount:${yandex_iam_service_account.k8saccount.id}"
  ]
}

# resource "yandex_kms_symmetric_key" "kms-key" {
#   name              = "kms-key"
#   default_algorithm = "AES_128"
#   rotation_period   = "8760h" # 1 год.
# }

# resource "yandex_kms_symmetric_key_iam_binding" "viewer" {
#   symmetric_key_id = yandex_kms_symmetric_key.kms-key.id
#   role             = "viewer"
#   members = [
#     "serviceAccount:${yandex_iam_service_account.k8saccount.id}",
#   ]
# }

resource "yandex_kubernetes_cluster" "k8s-zonal" {
  name       = var.cluster_name
  network_id = yandex_vpc_network.k8snetwork.id
  master {
    version = var.k8s_version
    zonal {
      zone      = yandex_vpc_subnet.k8ssubnet.zone
      subnet_id = yandex_vpc_subnet.k8ssubnet.id
    }
    public_ip = true
    security_group_ids = [
      yandex_vpc_security_group.k8s-main-sg.id,
      yandex_vpc_security_group.k8s-master-whitelist.id
    ]
  }
  service_account_id      = yandex_iam_service_account.k8saccount.id
  node_service_account_id = yandex_iam_service_account.k8saccount.id
  depends_on = [
    # yandex_resourcemanager_folder_iam_binding.k8s-clusters-agent,
    # yandex_resourcemanager_folder_iam_binding.vpc-public-admin,
    # yandex_resourcemanager_folder_iam_binding.images-puller
    yandex_resourcemanager_folder_iam_binding.admin
  ]
  # kms_provider {
  #   key_id = yandex_kms_symmetric_key.kms-key.id
  # }
}

resource "yandex_kubernetes_node_group" "k8s-nodes" {
  cluster_id = yandex_kubernetes_cluster.k8s-zonal.id
  name       = "k8s-nodes"
  version    = var.k8s_version
  instance_template {
    name        = "k8s-node-{instance.index}"
    platform_id = "standard-v1"
    network_interface {
      nat        = true
      subnet_ids = [yandex_vpc_subnet.k8ssubnet.id]
      security_group_ids = [
        yandex_vpc_security_group.k8s-main-sg.id,
        # yandex_vpc_security_group.k8s-nodes-ssh-access.id,
        yandex_vpc_security_group.k8s-public-services.id
      ]
    }
    container_runtime {
      type = "containerd"
    }
    resources {
      cores  = 2
      memory = 4
    }
    scheduling_policy {
      preemptible = var.preemptible
    }
    # labels {
    #   "<имя метки>"="<значение метки>"
    # }
  }
  scale_policy {
    auto_scale {
      min = 1
      max = var.max_scale
      initial = 1
    }
  }
  depends_on = [
    yandex_kubernetes_cluster.k8s-zonal
  ]
}


resource "null_resource" "kubectl" {
  provisioner "local-exec" {
    command = "yc managed-kubernetes cluster get-credentials ${var.cluster_name} --external --force"
  }
  depends_on = [
    yandex_kubernetes_node_group.k8s-nodes
  ]
}