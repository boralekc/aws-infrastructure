terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "0.120.0"
    }
  }
}

// Создание сервисного аккаунта
resource "yandex_iam_service_account" "postgres" {
  folder_id = var.folder_id
  name  = var.account_name
}

// Добавление прав сервисному аккаунту
resource "yandex_resourcemanager_folder_iam_binding" "admin" {
  folder_id = var.folder_id
  role      = "vpc.admin"
  members = [
    "serviceAccount:${yandex_iam_service_account.postgres.id}"
  ]
}

// Создание сети
resource "yandex_vpc_network" "postgres" {
  name = "${var.network_name}-network"
}

# Создание подсети
resource "yandex_vpc_subnet" "postgres" {
  name = "${var.network_name}-subnet"
  zone           = var.zone
  network_id     = yandex_vpc_network.postgres.id
  v4_cidr_blocks = ["10.0.0.0/24"]
}

# Создание кластера PostgreSQL
resource "yandex_mdb_postgresql_cluster" "postgresql196" {
  environment = var.environment
  name        = var.cluster_name
  network_id  = yandex_vpc_network.postgres.id

  config {
    version = var.postgres_version

    resources {
      disk_size          = var.disk_size
      disk_type_id       = var.disk_type_id
      resource_preset_id = var.resource_preset_id
    }
  }

  host {
    zone = var.host_zone
    assign_public_ip = true
  }
}

// Создание пользователя PostgreSQL
resource "yandex_mdb_postgresql_user" "postgres_user" {
  cluster_id = yandex_mdb_postgresql_cluster.postgresql196.id
  name       = var.db_user
  password   = var.db_password
}

resource "yandex_mdb_postgresql_database" "db_dev" {
  cluster_id = yandex_mdb_postgresql_cluster.postgresql196.id
  owner      = var.db_user
  name       = var.db_dev
}

resource "yandex_mdb_postgresql_database" "db_prod" {
  cluster_id = yandex_mdb_postgresql_cluster.postgresql196.id
  owner      = var.db_user
  name       = var.db_prod
}

resource "yandex_mdb_postgresql_database" "db_keycloak" {
  cluster_id = yandex_mdb_postgresql_cluster.postgresql196.id
  owner      = var.db_user
  name       = var.db_keycloak
}

resource "yandex_mdb_postgresql_database" "db_sonarqube" {
  cluster_id = yandex_mdb_postgresql_cluster.postgresql196.id
  owner      = var.db_user
  name       = var.db_sonarqube
}
