# Создание IAM пользователя
resource "aws_iam_user" "registry_user" {
  name = var.account_name
}

# Создание IAM политики для доступа к ECR
resource "aws_iam_policy" "ecr_policy" {
  name        = "ECRPolicy"
  description = "Policy for accessing ECR"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "ecr:ListImages",
          "ecr:DescribeRepositories",
          "ecr:CreateRepository",
          "ecr:DeleteRepository",
          "ecr:PutImage",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:PutImageTagMutability",
          "ecr:BatchGetImage"
        ]
        Resource = "*"
      }
    ]
  })
}

# Привязка политики к IAM пользователю
resource "aws_iam_user_policy_attachment" "ecr_policy_attachment" {
  user       = aws_iam_user.registry_user.name
  policy_arn = aws_iam_policy.ecr_policy.arn
}

# Создание ECR репозитория
resource "aws_ecr_repository" "courseway" {
  name = var.registry_name
}
