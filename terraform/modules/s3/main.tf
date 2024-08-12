# Определение ресурса бакета S3
resource "aws_s3_bucket" "s3" {
  bucket = var.bucket_name
  tags = {
    Name        = var.bucket_name
    Environment = var.environment
  }
}

# Определение ресурса версионирования S3
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.s3.bucket

  versioning_configuration {
    status = "Enabled"
  }
}

# Определение ресурса для настройки шифрования
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.s3.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
