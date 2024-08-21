provider "aws" {
  region = var.AWS_REGION
}

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