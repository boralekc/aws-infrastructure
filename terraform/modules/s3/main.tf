# Создание IAM пользователя
resource "aws_iam_user" "s3_user" {
  name = var.account_name
}

# Создание IAM политики для доступа к ECR
resource "aws_iam_policy" "s3_policy" {
  name        = "S3Policy"
  description = "Policy for accessing s3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "s3:ListBucket",
          "s3:CreateBucket",
          "s3:DeleteBucket",
          "s3:GetObject",
          "s3:PutObject",
        ]
        Resource = "*"
      }
    ]
  })
}

# Привязка политики к IAM пользователю
resource "aws_iam_user_policy_attachment" "s3_policy_attachment" {
  user       = aws_iam_user.s3_user.name
  policy_arn = aws_iam_policy.s3_policy.arn
}

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
