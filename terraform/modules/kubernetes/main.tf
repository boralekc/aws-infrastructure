# Создание VPC
resource "aws_vpc" "k8s_network" {
  cidr_block = "10.200.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "k8s-network"
  }
}

# Создание подсети a
resource "aws_subnet" "k8s_subnet_a" {
  vpc_id            = aws_vpc.k8s_network.id
  cidr_block        = "10.200.0.0/24"
  availability_zone = "${var.cluster_zone}a"
  map_public_ip_on_launch = true
  tags = {
    Name = "k8s-subnet-a"
  }
}

# Создание подсети b
resource "aws_subnet" "k8s_subnet_b" {
  vpc_id            = aws_vpc.k8s_network.id
  cidr_block        = "10.200.1.0/24"
  availability_zone = "${var.cluster_zone}b"
  map_public_ip_on_launch = true
  tags = {
    Name = "k8s-subnet-b"
  }
}

# Создание группы безопасности
resource "aws_security_group" "k8s_sg" {
  vpc_id = aws_vpc.k8s_network.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "k8s-sg"
  }
}

# Создание кластера EKS
resource "aws_eks_cluster" "k8s_cluster" {
  name     = var.cluster_name
  role_arn  = aws_iam_role.eks_role.arn
  version   = var.kubernetes_version
  vpc_config {
    subnet_ids = [
      aws_subnet.k8s_subnet_a.id,
      aws_subnet.k8s_subnet_b.id
    ]
    security_group_ids = [aws_security_group.k8s_sg.id]
  }

  tags = {
    Name = "k8s-cluster"
  }
}

# Создание роли IAM для EKS
resource "aws_iam_role" "eks_role" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "eks-role"
  }
}

# Политика IAM для роли EKS
resource "aws_iam_role_policy_attachment" "eks_policy" {
  role       = aws_iam_role.eks_role.name
  policy_arn  = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# Создание группы узлов (Node Group) для EKS
resource "aws_eks_node_group" "k8s_node_group" {
  cluster_name    = aws_eks_cluster.k8s_cluster.name
  node_role_arn   = aws_iam_role.node_role.arn
  subnet_ids = [
      aws_subnet.k8s_subnet_a.id,
      aws_subnet.k8s_subnet_b.id
    ]
  scaling_config {
    desired_size = var.node_desired_size
    max_size     = var.node_max_size
    min_size     = var.node_min_size
  }

  instance_types = ["t3.medium"] # Укажите тип инстанса EC2 для узлов

  tags = {
    Name = "k8s-node-group"
  }
}

# Создание роли IAM для узлов EKS
resource "aws_iam_role" "node_role" {
  name = "eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "node-role"
  }
}

# Политики IAM для роли узлов
resource "aws_iam_role_policy_attachment" "node_policy" {
  role       = aws_iam_role.node_role.name
  policy_arn  = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "cni_policy" {
  role       = aws_iam_role.node_role.name
  policy_arn  = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "ec2_policy" {
  role       = aws_iam_role.node_role.name
  policy_arn  = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
