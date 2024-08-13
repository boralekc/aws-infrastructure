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

module "rds" {
  source             = "./modules/rds"
  network_name       = "postgres"
  cluster_name       = "postgres"
  availability_zone  =  "eu-north-1a"
  postgres_version   =  15
  disk_size          = "10"
  instance_class     = "db.t3.medium"
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
  region      = var.AWS_REGION
  account_name = "s3"
}

module "registry" {
  source        = "./modules/registry"
  registry_name = "courseway"
  account_name  = "registry"
}

module "kubernetes" {
  source             = "./modules/kubernetes"
  node_desired_size  = 1
  node_max_size      = 1
  node_min_size      = 1
  region      = var.AWS_REGION
  kubernetes_version = "1.29"
  cluster_name       = "k8s"
  cluster_zone       = "eu-north-1a"
}
