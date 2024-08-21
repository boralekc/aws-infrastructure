# module "eks" {
#   source  = "terraform-aws-modules/eks/aws"
#   version = "~> 20.24"

#   cluster_name    = var.CLUSTER_NAME
#   cluster_version = "1.30"

#   cluster_endpoint_private_access = true
#   cluster_endpoint_public_access  = true

#   vpc_id = module.vpc.vpc_id
#   subnet_ids = [
#     module.vpc.private_subnets[1],
#     module.vpc.private_subnets[2]
#   ]

#   enable_irsa = true

#   eks_managed_node_group_defaults = {
#     disk_size = 50
#   }

#   eks_managed_node_groups = {
#     general = {
#       desired_size = 1
#       min_size     = 1
#       max_size     = 10

#       labels = {
#         role = "general"
#       }

#       instance_types = ["t3.small"]
#       capacity_type  = "ON_DEMAND"
#     }

#     spot = {
#       desired_size = 1
#       min_size     = 1
#       max_size     = 10

#       labels = {
#         role = "spot"
#       }

#       taints = [{
#         key = "market"
#         value = "spot"
#         effect = "NO_SHEDULE"
#       }]

#       instance_types = ["t3.micro"]
#       capacity_type  = "SPOT"
#     }
#   }

#   cluster_addons = {
#     coredns                = {}
#     eks-pod-identity-agent = {}
#     kube-proxy             = {}
#     vpc-cni                = {}
#   }
 
#   # Cluster access entry
#   # To add the current caller identity as an administrator
#   enable_cluster_creator_admin_permissions = true

#   access_entries = {
#     # One access entry with a policy associated
#     terraform_access = {
#       kubernetes_groups = []
#       principal_arn     = "arn:aws:iam::975050337330:role/terraform"

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