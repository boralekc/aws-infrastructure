variable "eks_cluster_name" {
  type = string
}

variable "subnet_a" {
  description = "Availability zone for subnet."
  type        = string
}

variable "subnet_b" {
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