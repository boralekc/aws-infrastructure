terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.62.0"
    }
  }

  backend "s3" {
    bucket         = "courseway"  # Замените на имя вашего бакета S3
    key            = "terraform-state/terraform.tfstate"  # Путь к файлу состояния внутри бакета
    region         = "eu-north-1" # Замените на регион, в котором находится ваш бакет
    encrypt        = true  # Включает шифрование данных в бакете S3
  }
}

provider "aws" {
  region = var.AWS_REGION
}

# module "postgres" {
#   source             = "./modules/postgres"
#   folder_id          = var.FOLDER_ID
#   account_name       = "postgres"
#   network_name       = "postgres"
#   cluster_name       = "postgres"
#   zone               = "ru-central1-a"
#   environment        = "PRODUCTION"
#   postgres_version   = 15
#   disk_size          = "10"
#   disk_type_id       = "network-ssd"
#   resource_preset_id = "b2.medium"
#   host_zone          = "ru-central1-a"
#   db_user            = var.DB_USER
#   db_password        = var.DB_PASSWORD
#   db_dev             = "sw-site-db-dev"
#   db_prod            = "sw-site-db-prod"
#   db_keycloak        = "db-keycloak"
#   db_sonarqube       = "sonarDB"
# }

module "s3" {
  source      = "./modules/s3"
  bucket_name = "courseway-bucket"
  region      = var.AWS_REGION
}

# module "registry" {
#   source        = "./modules/registry"
#   folder_id     = var.FOLDER_ID
#   registry_name = "courseway"
#   account_name  = "registry"
# }

# module "kubernetes" {
#   source             = "./modules/kubernetes"
#   folder_id          = var.FOLDER_ID
#   cluster_name       = "k8s"
#   cluster_group_name = "k8s-node-group"
#   kubernetes_verison = "1.29"
#   platform_id        = "standard-v2"
#   cluster_zone       = "ru-central1-a"
#   account_name       = "k8s-sa"
#   count_worker_node  = "1"
#   node_ram           = 4
#   node_cores         = 4
#   disk_type          = "network-ssd"
#   disk_size           = 64
# }
