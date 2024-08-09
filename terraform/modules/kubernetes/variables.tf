variable "folder_id" {
  description = "Folder ID where resources will be created"
  type        = string
}

variable "cluster_name" {
  description = "Name for IAM account"
  type        = string
}

variable "cluster_group_name" {
  description = "Name cluster group"
  type        = string
}

variable "kubernetes_verison" {
  description = "Kubernetes version"
  type        = number
}

variable "platform_id" {
  description = "CPU and RAM variant"
  type        = string
}

variable "cluster_zone" {
  description = "Cluster zone"
  type        = string
}

variable "account_name" {
  description = "Account name"
  type        = string
}

variable "count_worker_node" {
  description = "Count worder nods"
  type        = number
}

variable "node_ram" {
  description = "Node ram"
  type        = number
}

variable "node_cores" {
  description = "Node cores"
  type        = number
}

variable "disk_type" {
  description = "Disk type"
  type        = string
}

variable "disk_size" {
  description = "Disk size"
  type        = number
}