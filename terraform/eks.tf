# module "eks-vpc" {
#   source  = "terraform-aws-modules/vpc/aws"
#   version = "~> 5.13"

#   name                = "eks-vpc"
#   cidr                = "10.0.0.0/16"

#   azs                 = ["eu-north-1a", "eu-north-1b"]

#   public_subnets      = ["10.0.1.0/24", "10.0.2.0/24"]
#   private_subnets     = ["10.0.11.0/24", "10.0.12.0/24"]
#   intra_subnets       = ["10.0.21.0/24", "10.0.22.0/24"]

#   enable_dns_support  = true
#   enable_dns_hostnames = true
#   enable_nat_gateway = true
#   single_nat_gateway = true
#   one_nat_gateway_per_az = false

#   tags = {
#     Name = "eks-vpc"
#   }
# }

# # Создание IAM роли для EKS
# resource "aws_iam_role" "eks_role" {
#   name = "k8s"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Principal = {
#           Service = "eks.amazonaws.com"
#         }
#         Action = "sts:AssumeRole"
#       },
#     ]
#   })

#   tags = {
#     Name = "eks-role"
#   }
# }

# # Привязка политики AmazonEKSClusterPolicy
# resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
#   role     = aws_iam_role.eks_role.name
# }

# # Привязка политики AmazonEKSVPCResourceController
# resource "aws_iam_role_policy_attachment" "eks_vpc_policy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
#   role     = aws_iam_role.eks_role.name
# }

# module "eks" {
#   source  = "terraform-aws-modules/eks/aws"
#   version = "~> 20.24"

#   cluster_name    = var.CLUSTER_NAME
#   cluster_version = "1.30"

#   cluster_endpoint_public_access  = true

#   cluster_addons = {
#     coredns                = {}
#     eks-pod-identity-agent = {}
#     kube-proxy             = {}
#     vpc-cni                = {}
#   }

#   vpc_id                   = module.eks-vpc.vpc_id
#   subnet_ids               = module.eks-vpc.private_subnets
#   control_plane_subnet_ids = module.eks-vpc.intra_subnets

#   eks_managed_node_group_defaults = {
#     disk_size = 50
#   }

#   eks_managed_node_groups = {
#     courseway = {
#       ami_type       = "AL2023_x86_64_STANDARD"
#       instance_types = ["t3.small"]

#       min_size     = 2
#       max_size     = 10
#       desired_size = 2
#     }
#   }

#   # Cluster access entry
#   enable_cluster_creator_admin_permissions = true

#   access_entries = {
#     terraform_access = {
#       kubernetes_groups = []
#       principal_arn     = aws_iam_role.eks_role.arn

#       policy_associations = {
#         example = {
#           policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
#           access_scope = {
#             namespaces = ["default"]
#             type       = "namespace"
#           }
#         }
#       }
#     }
#   }
# }
