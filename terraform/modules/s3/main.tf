terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "0.120.0"
    }
  }
}

// Создание сервисного аккаунта
resource "yandex_iam_service_account" "bucket" {
  folder_id = var.folder_id
  name      = var.bucket_name
}

resource "yandex_resourcemanager_folder_iam_binding" "admin" {
  # Сервисному аккаунту назначается роль "editor".
  folder_id = var.folder_id
  role      = "storage.admin"
  members = [
    "serviceAccount:${yandex_iam_service_account.bucket.id}"
  ]
}

// Create Static Access Keys
resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.bucket.id
  description        = "static access key for object storage"
}

// Use keys to create bucket
resource "yandex_storage_bucket" "s3" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket = var.bucket_name
  acl = "public-read"
}