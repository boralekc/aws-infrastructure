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
  availability_zone  =  var.AWS_REGION
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

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.CLUSTER_NAME
  cluster_version = "1.30"

  cluster_endpoint_public_access  = true

  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  vpc_id                   = "vpc-1234556abcdef"
  subnet_ids               = ["subnet-abcde012", "subnet-bcde012a", "subnet-fghi345a"]
  control_plane_subnet_ids = ["subnet-xyzde987", "subnet-slkjf456", "subnet-qeiru789"]

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
  }

  eks_managed_node_groups = {
    example = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["m5.xlarge"]

      min_size     = 1
      max_size     = 1
      desired_size = 1
    }
  }

  # Cluster access entry
  # To add the current caller identity as an administrator
  enable_cluster_creator_admin_permissions = true

  access_entries = {
    # One access entry with a policy associated
    example = {
      kubernetes_groups = []
      principal_arn     = "arn:aws:iam::123456789012:role/something"

      policy_associations = {
        example = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
          access_scope = {
            namespaces = ["default"]
            type       = "namespace"
          }
        }
      }
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

# module "k8s" {
#   source             = "./modules/k8s"
#   node_desired_size  = 1
#   node_max_size      = 1
#   node_min_size      = 1
#   region             = var.AWS_REGION
#   kubernetes_version = "1.30"
#   cluster_name       = var.CLUSTER_NAME
#   cluster_zone       = var.AWS_REGION
# }

module "eks_node_group" {
  source             = "./modules/eks_node_group"
  eks_cluster_name   = module.k8s.cluster_name
  node_desired_size  = 1
  node_max_size      = 1
  node_min_size      = 1
  subnet_a           = module.k8s.subnet_a
  subnet_b           = module.k8s.subnet_b
}
