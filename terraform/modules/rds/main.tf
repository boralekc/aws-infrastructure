# Создание VPC
resource "aws_vpc" "postgres" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.network_name}-vpc"
  }
}

# Создание подсети
resource "aws_subnet" "postgres" {
  vpc_id     = aws_vpc.postgres.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "${var.availability_zone}a"
  tags = {
    Name = "${var.network_name}-subnet"
  }
}

# Создание группы безопасности
resource "aws_security_group" "postgres" {
  vpc_id = aws_vpc.postgres.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.network_name}-sg"
  }
}

# Создание кластера PostgreSQL
resource "aws_db_instance" "postgres" {
  identifier        = var.cluster_name
  engine            = "postgres"
  engine_version    = var.postgres_version
  instance_class    = var.instance_class
  allocated_storage = var.disk_size
  storage_type      = "gp2"

  # Используйте параметры для сетевого доступа и безопасности
  vpc_security_group_ids = [aws_security_group.postgres.id]
  db_subnet_group_name    = aws_db_subnet_group.postgres.id

  # Настройки резервного копирования
  backup_retention_period = 7

  # Создание пользователя базы данных
  username = var.db_user
  password = var.db_password
  parameter_group_name = "default.postgres12"  # Замените на нужную версию PostgreSQL

  tags = {
    Name = "${var.cluster_name}-db-instance"
  }
}

# Создание группы подсетей для RDS
resource "aws_db_subnet_group" "postgres" {
  name       = "${var.network_name}-db-subnet-group"
  subnet_ids = [aws_subnet.postgres.id]

  tags = {
    Name = "${var.network_name}-db-subnet-group"
  }
}

# Создание базы данных (так как в AWS RDS можно создавать базы данных через SQL команды)
resource "null_resource" "initialize_database" {
  provisioner "local-exec" {
    command = <<EOT
      PGPASSWORD=${var.db_password} psql -h ${aws_db_instance.postgres.address} -U ${var.db_user} -d postgres -c "CREATE DATABASE ${var.db_dev};"
      PGPASSWORD=${var.db_password} psql -h ${aws_db_instance.postgres.address} -U ${var.db_user} -d postgres -c "CREATE DATABASE ${var.db_prod};"
      PGPASSWORD=${var.db_password} psql -h ${aws_db_instance.postgres.address} -U ${var.db_user} -d postgres -c "CREATE DATABASE ${var.db_keycloak};"
      PGPASSWORD=${var.db_password} psql -h ${aws_db_instance.postgres.address} -U ${var.db_user} -d postgres -c "CREATE DATABASE ${var.db_sonarqube};"
    EOT

    environment = {
      PGPASSWORD = var.db_password
    }
  }
}