terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "0.120.0"
    }
  }
}

resource "yandex_iam_service_account" "registry" {
    description = "Сервисный аккаунт для сервиса Container Registry"
    folder_id   = var.folder_id
    name        = var.account_name
}

resource "yandex_resourcemanager_folder_iam_binding" "admin" {
  folder_id = var.folder_id
  role      = "container-registry.admin"
  members = [
    "serviceAccount:${yandex_iam_service_account.registry.id}"
  ]
}

resource "yandex_container_registry" "courseway" {
    folder_id  = var.folder_id
    name       = var.registry_name
}