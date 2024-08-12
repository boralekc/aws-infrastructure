variable "region" {
  description = "AWS region to deploy resources in."
  type        = string
}

variable "network_name" {
  description = "Name of the network."
  type        = string
}

variable "availability_zone" {
  description = "Availability zone for subnet."
  type        = string
}

variable "postgres_version" {
  description = "PostgreSQL engine version."
  type        = string
}

variable "instance_class" {
  description = "Instance class for the RDS instance."
  type        = string
}

variable "disk_size" {
  description = "Size of the storage in GB."
  type        = number
}

variable "db_user" {
  description = "Database user name."
  type        = string
}

variable "db_password" {
  description = "Database user password."
  type        = string
  sensitive   = true
}

variable "db_dev" {
  description = "Name of the development database."
  type        = string
}

variable "db_prod" {
  description = "Name of the production database."
  type        = string
}

variable "db_keycloak" {
  description = "Name of the Keycloak database."
  type        = string
}

variable "db_sonarqube" {
  description = "Name of the SonarQube database."
  type        = string
}