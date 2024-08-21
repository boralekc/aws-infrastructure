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

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.13"

  name                = "eks-rds-vpc"
  cidr                = "10.0.0.0/16"

  azs                 = ["eu-north-1a", "eu-north-1b"]

  # Публичные подсети для EKS
  public_subnets      = ["10.0.1.0/24", "10.0.2.0/24"]

  # Приватные подсети для EKS и RDS
  private_subnets     = [
    "10.0.11.0/24", "10.0.12.0/24",  # Для EKS
    "10.0.21.0/24", "10.0.22.0/24",  # Для RDS
  ]

  enable_dns_support  = true
  enable_dns_hostnames = true
  enable_nat_gateway = true
  single_nat_gateway = true
  one_nat_gateway_per_az = false

  tags = {
    Name = "eks-rds-vpc"
  }
}

module "db" {
  source = "terraform-aws-modules/rds/aws"
  
  identifier = "courseway"
  
  engine            = "postgres"
  engine_version    = "15"
  instance_class    = "db.t3.medium"
  allocated_storage = 20
  
  db_name  = "proddb"
  username = var.DB_USER
  password = var.DB_PASSWORD
  port     = "5432"

  manage_master_user_password = false
  
  iam_database_authentication_enabled = true
  
  # vpc_security_group_ids = ["sg-12345678"]
  
  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"
  
  # Enhanced Monitoring - see example for details on how to create the role
  # by yourself, in case you don't want to create it automatically
  monitoring_interval    = "30"
  monitoring_role_name   = "courseway-postgres"
  create_monitoring_role = true
  
  tags = {
    Owner       = "user"
    Environment = "dev"
  }
  
  # DB subnet group
  create_db_subnet_group = true
  subnet_ids             = [
    module.vpc.private_subnets[3],  # 10.0.21.0/24
    module.vpc.private_subnets[4],  # 10.0.22.0/24
  ]
  
  # DB parameter group
  family = "postgres15"
  
  # DB option group
  major_engine_version = "15"
  
  # Database Deletion Protection
  deletion_protection = true
}

# resource "null_resource" "init_db" {
#   depends_on = [module.db]
  
#   provisioner "local-exec" {
#     command = <<EOT
#       PGPASSWORD=${var.DB_PASSWORD} psql -h ${module.db.endpoint} -U ${var.DB_USER} -d main_db -c "CREATE DATABASE sw-site-db-dev;"
#       PGPASSWORD=${var.DB_PASSWORD} psql -h ${module.db.endpoint} -U ${var.DB_USER} -d main_db -c "CREATE DATABASE db-keycloak;"
#     EOT
#   }
# }


  # parameters = [
  #   {
  #     name  = "character_set_client"
  #     value = "utf8mb4"
  #   },
  #   {
  #     name  = "character_set_server"
  #     value = "utf8mb4"
  #   }
  # ]

  # options = [
  #   {
  #     option_name = "MARIADB_AUDIT_PLUGIN"

  #     option_settings = [
  #       {
  #         name  = "SERVER_AUDIT_EVENTS"
  #         value = "CONNECT"
  #       },
  #       {
  #         name  = "SERVER_AUDIT_FILE_ROTATIONS"
  #         value = "37"
  #       },
  #     ]
  #   },
  # ]

# module "rds" {
#   source             = "./modules/rds"
#   network_name       = "postgres"
#   cluster_name       = "postgres"
#   availability_zone  =  var.AWS_REGION
#   postgres_version   =  15
#   disk_size          = "10"
#   instance_class     = "db.t3.medium"
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
  account_name = "s3"
}

module "registry" {
  source        = "./modules/registry"
  registry_name = "courseway"
  account_name  = "registry"
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.24"

  cluster_name    = var.CLUSTER_NAME
  cluster_version = "1.30"

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  vpc_id = module.vpc.vpc_id
  subnet_ids = [
    module.vpc.private_subnets[1],
    module.vpc.private_subnets[2]
  ]

  enable_irsa = true

  eks_managed_node_group_defaults = {
    disk_size = 50
  }

  eks_managed_node_groups = {
    general = {
      desired_size = 1
      min_size     = 1
      max_size     = 10

      labels = {
        role = "general"
      }

      instance_types = ["t3.small"]
      capacity_type  = "ON_DEMAND"
    }

    spot = {
      desired_size = 1
      min_size     = 1
      max_size     = 10

      labels = {
        role = "spot"
      }

      taints = [{
        key = "market"
        value = "spot"
        effect = "NO_SHEDULE"
      }]

      instance_types = ["t3.micro"]
      capacity_type  = "SPOT"
    }
  }

  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }
 
  # Cluster access entry
  # To add the current caller identity as an administrator
  enable_cluster_creator_admin_permissions = true

  access_entries = {
    # One access entry with a policy associated
    terraform_access = {
      kubernetes_groups = []
      principal_arn     = "arn:aws:iam::975050337330:role/terraform"

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

# module "allow_eks_access_iam_policy" {
#   source = "terraform-aws-modules/iam/aws//modules/iam-policy"
#   version = "5.44.0"

#   name = "allow-eks-access"
#   create_policy = true

#   policy = jsondecode({
#     Version = "2024-08-21"
#     Statement = [
#       {
#         Action = [
#           "eks:DescribeCluster",
#         ]
#         Effect = "Allow"
#         Resource = "*"
#       },
#     ]
#   })
# }

# module "eks_admins_access_iam_role" {
#   source = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
#   version = "5.44.0"

#   role_name = "eks-admin"
#   create_role = true
#   role_requires_mfa = false

#   custom_role_policy_arns = [module.allow_eks_access_iam_policy.arn]

#   trusted_role_arns = [
#     "arn:aws:iam::${module.vpc.vpc_owner_id}:root"
#   ]
# }

# module "k8s_iam_user" {
#   source  = "terraform-aws-modules/iam/aws//modules/iam-user"

#   name          = "k8s"
#   create_iam_access_key = false
#   create_iam_user_login_profile = false

#   force_destroy = true
# }

# module "allow_assume_eks_admins_iam_policy" {
#   source = "terraform-aws-modules/iam/aws//modules/iam-policy"
#   version = "5.44.0"

#   name = "allow-assume_eks_admins_iam_role"
#   create_policy = true

#   policy = jsondecode({
#     Version = "2024-08-21"
#     Statement = [
#       {
#         Action = [
#           "sts:AssumeRole",
#         ]
#         Effect = "Allow"
#         Resource = "module.eks_admins_iam_role.iam_role_arn"
#       },
#     ]
#   })
# }

# module "iam_group_with_policies" {
#   source  = "terraform-aws-modules/iam/aws//modules/iam-group-with-policies"
#   version = "5.44.0"

#   name = "eks-admin"
#   create_group = true


#   group_users = [ module.k8s_iam_user.iam_user_name ]

#   attach_iam_self_management_policy = true

#   custom_group_policy_arns = [
#     "arn:aws:iam::aws:policy/AdministratorAccess",
#   ]

#   custom_group_policies = [
#     {
#       name   = "AllowS3Listing"
#       policy = data.aws_iam_policy_document.sample.json
#     }
#   ]
# }

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

# module "eks_node_group" {
#   source             = "./modules/eks_node_group"
#   eks_cluster_name   = module.k8s.cluster_name
#   node_desired_size  = 1
#   node_max_size      = 1
#   node_min_size      = 1
#   subnet_a           = module.k8s.subnet_a
#   subnet_b           = module.k8s.subnet_b
# }
