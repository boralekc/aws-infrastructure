terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.120.0"
    }
  }

  backend "s3" {
    endpoints = {
      s3 = "https://storage.yandexcloud.net"
    }
    bucket = "courseway"
    region = "ru-central1"
    key    = "terraform-state/terraform.tfstate"

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true # This option is required to describe backend for Terraform version 1.6.1 or higher.
    skip_s3_checksum            = true # This option is required to describe backend for Terraform version 1.6.3 or higher.
  }
}

provider "yandex" {
  cloud_id                 = var.CLOUD_ID
  folder_id                = var.FOLDER_ID
  zone                     = "ru-central1-a"
  service_account_key_file = var.YC_TOKEN != "" ? "" : "D:\\Dev\\yandex-key\\authorized_key.json"
}

module "postgres" {
  source             = "./modules/postgres"
  folder_id          = var.FOLDER_ID
  account_name       = "postgres"
  network_name       = "postgres"
  cluster_name       = "postgres"
  zone               = "ru-central1-a"
  environment        = "PRODUCTION"
  postgres_version   = 15
  disk_size          = "10"
  disk_type_id       = "network-ssd"
  resource_preset_id = "b2.medium"
  host_zone          = "ru-central1-a"
  db_user            = var.DB_USER
  db_password        = var.DB_PASSWORD
  db_dev             = "sw-site-db-dev"
  db_prod            = "sw-site-db-prod"
  db_keycloak        = "db-keycloak"
  db_sonarqube       = "sonarDB"
}

module "s3" {
  source      = "./modules/s3"
  bucket_name = "courseway-bucket"
  folder_id   = var.FOLDER_ID
}

module "registry" {
  source        = "./modules/registry"
  folder_id     = var.FOLDER_ID
  registry_name = "courseway"
  account_name  = "registry"
}

module "kubernetes" {
  source             = "./modules/kubernetes"
  folder_id          = var.FOLDER_ID
  cluster_name       = "k8s"
  cluster_group_name = "k8s-node-group"
  kubernetes_verison = "1.29"
  platform_id        = "standard-v2"
  cluster_zone       = "ru-central1-a"
  account_name       = "k8s-sa"
  count_worker_node  = "1"
  node_ram           = 4
  node_cores         = 4
  disk_type          = "network-ssd"
  disk_size           = 64
}
