# module "rds-vpc" {
#   source  = "terraform-aws-modules/vpc/aws"
#   version = "~> 5.13"

#   name                = "rds-vpc"
#   cidr                = "10.200.0.0/16"

#   azs                 = ["eu-north-1a", "eu-north-1b"]

#   public_subnets      = ["10.200.1.0/24", "10.200.2.0/24"]
#   private_subnets     = ["10.200.11.0/24", "10.200.12.0/24"]

#   enable_dns_support  = true
#   enable_dns_hostnames = true
#   enable_nat_gateway = true
#   single_nat_gateway = true
#   one_nat_gateway_per_az = false

#   tags = {
#     Name = "rds-vpc"
#   }
# }

# module "devdb" {
#   source = "terraform-aws-modules/rds/aws"
  
#   identifier = "courseway-dev"
  
#   engine            = "postgres"
#   engine_version    = "16"
#   instance_class    = "db.t3.medium"
#   allocated_storage = 20
  
#   db_name  = "devdb"
#   username = var.DB_USER
#   password = var.DB_PASSWORD
#   port     = "5432"

#   manage_master_user_password = false
#   iam_database_authentication_enabled = true

#   maintenance_window = "Mon:00:00-Mon:03:00"
#   backup_window      = "03:00-06:00"

#   monitoring_interval    = "30"
#   monitoring_role_name   = "courseway-dev"
#   create_monitoring_role = true
  
#   tags = {
#     Owner       = "user"
#     Environment = "dev"
#   }
  
#   # DB subnet group
#   create_db_subnet_group = true
#   subnet_ids             = module.rds-vpc.private_subnets
  
#   # DB parameter group
#   family = "postgres16"
  
#   # DB option group
#   major_engine_version = "16"
  
#   # Database Deletion Protection
#   deletion_protection = true
# }

# module "proddb" {
#   source = "terraform-aws-modules/rds/aws"
  
#   identifier = "courseway-prod"
  
#   engine            = "postgres"
#   engine_version    = "16"
#   instance_class    = "db.t3.medium"
#   allocated_storage = 20
  
#   db_name  = "proddb"
#   username = var.DB_USER
#   password = var.DB_PASSWORD
#   port     = "5432"

#   manage_master_user_password = false
#   iam_database_authentication_enabled = true

#   maintenance_window = "Mon:00:00-Mon:03:00"
#   backup_window      = "03:00-06:00"

#   monitoring_interval    = "30"
#   monitoring_role_name   = "courseway-prod"
#   create_monitoring_role = true
  
#   tags = {
#     Owner       = "user"
#     Environment = "dev"
#   }
  
#   # DB subnet group
#   create_db_subnet_group = true
#   subnet_ids             = module.rds-vpc.private_subnets
  
#   # DB parameter group
#   family = "postgres16"
  
#   # DB option group
#   major_engine_version = "16"
  
#   # Database Deletion Protection
#   deletion_protection = true
# }

# module "keycloakdb" {
#   source = "terraform-aws-modules/rds/aws"
  
#   identifier = "keycloak"
  
#   engine            = "postgres"
#   engine_version    = "16"
#   instance_class    = "db.t3.medium"
#   allocated_storage = 20
  
#   db_name  = "keycloakdb"
#   username = var.DB_USER
#   password = var.DB_PASSWORD
#   port     = "5432"

#   manage_master_user_password = false
#   iam_database_authentication_enabled = true

#   maintenance_window = "Mon:00:00-Mon:03:00"
#   backup_window      = "03:00-06:00"

#   monitoring_interval    = "30"
#   monitoring_role_name   = "courseway-keycloak"
#   create_monitoring_role = true
  
#   tags = {
#     Owner       = "user"
#     Environment = "dev"
#   }
  
#   # DB subnet group
#   create_db_subnet_group = true
#   subnet_ids             = module.rds-vpc.private_subnets
  
#   # DB parameter group
#   family = "postgres16"
  
#   # DB option group
#   major_engine_version = "16"
  
#   # Database Deletion Protection
#   deletion_protection = true
# }