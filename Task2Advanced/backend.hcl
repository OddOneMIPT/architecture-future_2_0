# Не-секретная часть конфигурации backend, передаётся при init:
#   terraform init -backend-config=backend.hcl
# Адрес S3-эндпоинта вынесен сюда, чтобы не хардкодить его в коде и
# легко переключать между MinIO / Yandex Object Storage / AWS S3.
endpoints = {
  s3 = "http://localhost:9000"
}
