variable "region" {
  description = "AWS region to deploy resources in."
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
}

variable "kubernetes_version" {
  description = "Version of Kubernetes to use."
  type        = string
}

variable "cluster_zone" {
  description = "Availability zone for subnet."
  type        = string
}

variable "node_desired_size" {
  description = "Desired number of worker nodes."
  type        = number
}

variable "node_max_size" {
  description = "Maximum number of worker nodes."
  type        = number
}

variable "node_min_size" {
  description = "Minimum number of worker nodes."
  type        = number
}