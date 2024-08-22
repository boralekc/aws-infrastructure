module "eks-vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.13"

  name                = "eks-vpc"
  cidr                = "10.0.0.0/16"

  azs                 = ["eu-north-1a", "eu-north-1b"]

  public_subnets      = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets     = ["10.0.11.0/24", "10.0.12.0/24"]
  intra_subnets       = ["10.0.21.0/24", "10.0.22.0/24"]

  enable_dns_support  = true
  enable_dns_hostnames = true
  enable_nat_gateway = true
  single_nat_gateway = true
  one_nat_gateway_per_az = false

  tags = {
    Name = "eks-vpc"
  }
}

module "iam_role" {
  source          = "terraform-aws-modules/iam/aws"
  version         = "~> 6.0"

  name            = "k8s"
  path            = "/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Service = "eks.amazonaws.com"  # Может быть другим сервисом в зависимости от вашей настройки
        }
      }
    ]
  })

  tags = {
    Name = "k8s"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.24"

  cluster_name    = var.CLUSTER_NAME
  cluster_version = "1.30"

  cluster_endpoint_public_access  = true

  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  vpc_id                   = module.eks-vpc.vpc_id
  subnet_ids               = module.eks-vpc.private_subnets
  control_plane_subnet_ids = module.eks-vpc.intra_subnets

  eks_managed_node_group_defaults = {
    disk_size = 50
  }

  eks_managed_node_groups = {
    courseway = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["t3.small"]

      min_size     = 2
      max_size     = 10
      desired_size = 2
    }
  }
 
  # Cluster access entry
  # To add the current caller identity as an administrator
  enable_cluster_creator_admin_permissions = true

  access_entries = {
    # One access entry with a policy associated
    terraform_access = {
      kubernetes_groups = []
      principal_arn     = "arn:aws:iam::975050337330:role/k8s"

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
}