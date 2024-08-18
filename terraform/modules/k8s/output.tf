output "cluster_name" {
  value = aws_eks_cluster.k8s_cluster.name
}

output "subnet_a" {
  value = aws_subnet.k8s_subnet_a.id
}

output "subnet_b" {
  value = aws_subnet.k8s_subnet_b.id
}