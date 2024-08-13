variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "environment" {
  description = "Environment (e.g., dev, prod)"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "The AWS region where the S3 bucket will be created"
  type        = string
}

variable "account_name" {
  description = "The name of the S3 bucket"
  type        = string
}
