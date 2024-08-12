provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "s3" {
  bucket = var.bucket_name
  acl    = "public-read"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name        = var.bucket_name
    Environment = var.environment
  }
}
