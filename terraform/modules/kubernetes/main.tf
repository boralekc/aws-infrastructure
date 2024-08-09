terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "0.120.0"
    }
  }
}

resource "yandex_kubernetes_cluster" "k8s-master" {
  name        = var.cluster_name
  description = "k8s master"

  network_id = yandex_vpc_network.k8s-network.id
  master {
    version = var.kubernetes_verison
    zonal {
      zone      = yandex_vpc_subnet.k8s-subnet.zone
      subnet_id = yandex_vpc_subnet.k8s-subnet.id
    }
    public_ip = true
  }

  service_account_id      = yandex_iam_service_account.k8s-sa.id
  node_service_account_id = yandex_iam_service_account.k8s-sa.id
  depends_on = [
    yandex_resourcemanager_folder_iam_binding.editor,
    yandex_resourcemanager_folder_iam_binding.images-puller
  ]
}

resource "yandex_kubernetes_node_group" "k8s_node_group" {
  cluster_id  = yandex_kubernetes_cluster.k8s-master.id
  name        = var.cluster_group_name
  description = "k8s node"
  version     = var.kubernetes_verison

  instance_template {
    platform_id = var.platform_id

    network_interface {
      nat        = true
      subnet_ids = ["${yandex_vpc_subnet.k8s-subnet.id}"]
    }

    resources {
      memory = var.node_ram
      cores  = var.node_cores
    }

    boot_disk {
      type = var.disk_type
      size = var.disk_size
    }

    scheduling_policy {
      preemptible = false
    }

    container_runtime {
      type = "containerd"
    }
  }

  scale_policy {
    fixed_scale {
      size = var.count_worker_node
    }
  }

  allocation_policy {
    location {
      zone = var.cluster_zone
    }
  }
}

resource "yandex_vpc_network" "k8s-network" { name = "k8s-network" }

resource "yandex_vpc_subnet" "k8s-subnet" {
  v4_cidr_blocks = ["10.200.0.0/24"]
  zone           = var.cluster_zone
  network_id     = yandex_vpc_network.k8s-network.id
}

resource "yandex_iam_service_account" "k8s-sa" {
  name        = var.account_name
  description = "k8s iam service account"
}

resource "yandex_resourcemanager_folder_iam_binding" "editor" {
  # Сервисному аккаунту назначается роль "editor".
  folder_id = var.folder_id
  role      = "editor"
  members = [
    "serviceAccount:${yandex_iam_service_account.k8s-sa.id}"
  ]
}

resource "yandex_resourcemanager_folder_iam_binding" "images-puller" {
  # Сервисному аккаунту назначается роль "container-registry.images.puller".
  folder_id = var.folder_id
  role      = "container-registry.images.puller"
  members = [
    "serviceAccount:${yandex_iam_service_account.k8s-sa.id}"
  ]
}