###############################################################################
# Удалённое состояние Terraform в S3-совместимом хранилище (MinIO).
# Состояние НЕ хранится локально.
#
# Не-секретные параметры backend заданы здесь; динамические значения
# (endpoint, креды) передаются через `-backend-config=...` и переменные
# окружения AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY при `terraform init`.
###############################################################################
terraform {
  backend "s3" {
    bucket = "future20-tfstate"
    key    = "task2/terraform.tfstate"
    region = "us-east-1"

    # S3-native блокировка состояния (без DynamoDB).
    use_lockfile = true

    # Флаги для не-AWS S3 (MinIO): путь-стайл и отключение AWS-специфичных проверок.
    use_path_style              = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true

    # endpoints.s3 передаётся через -backend-config (см. README / CI),
    # чтобы не хардкодить адрес окружения в коде.
  }
}
