variable "folder_id" {
  description = "Folder ID where resources will be created"
  type        = string
}

variable "account_name" {
  description = "Name for IAM account"
  type        = string
}

variable "network_name" {
  description = "Name for network"
  type        = string
}

variable "cluster_name" {
  description = "Name for postgres cluster"
  type        = string
}

variable "zone" {
  description = "Name for zone"
  type        = string
}

variable "host_zone" {
  description = "Name for host zone"
  type        = string
}

variable "environment" {
  description = "Name for environment"
  type        = string
}

variable "postgres_version" {
  description = "Version postgres"
  type        = number
}

variable "disk_size" {
  description = "Disk size"
  type        = number
}

variable "disk_type_id" {
  description = "Type for disk"
  type        = string
}

variable "resource_preset_id" {
  description = "CPU and RAM config type"
  type        = string
}

variable "db_user" {
  description = "Postgres user"
  type        = string
}

variable "db_password" {
  description = "Postgres user password"
  type        = string
}

variable "db_dev" {
  description = "Database dev name"
  type        = string
}

variable "db_prod" {
  description = "Database prod name"
  type        = string
}

variable "db_keycloak" {
  description = "Database keycloak name"
  type        = string
}

variable "db_sonarqube" {
  description = "Database sonarqube name"
  type        = string
}

