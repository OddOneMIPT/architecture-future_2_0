# Task2Advanced — CI/CD и удалённое хранение состояния

Тот же модуль ВМ, что и в Task1, но состояние Terraform хранится **удалённо** в
S3-совместимом хранилище (локально — **MinIO**), а развёртывание автоматизировано через
**GitHub Actions**. Состояние **не хранится локально**.

## Что внутри

```
Task2Advanced/
├── backend.tf                # backend "s3" (MinIO/S3): use_path_style, use_lockfile, skip_*
├── backend.hcl               # не-секретная часть backend (endpoint) для локального init
├── versions.tf               # провайдер docker, required_version >= 1.10
├── main.tf                   # сеть + module "vm" с source = "../Task1Advanced/modules/vm"
├── variables.tf
├── prod.tfvars               # пример конфигурации окружения
├── docker-compose.minio.yml  # локальный MinIO + автосоздание бакета
└── logs/                     # логи реального прогона (init/plan/apply/state)

../.github/workflows/terraform.yml  # пайплайн CI/CD (в корне репозитория)
```

Модуль ВМ переиспользуется из Task1 (`source = "../Task1Advanced/modules/vm"`) — отдельной
копии кода нет.

## Удалённый backend (S3 / MinIO)

`backend.tf` использует S3-бэкенд с флагами для не-AWS хранилищ:

| Параметр                      | Назначение                                            |
|-------------------------------|-------------------------------------------------------|
| `use_path_style = true`       | path-style URL (`endpoint/bucket`) — нужно MinIO      |
| `use_lockfile = true`         | блокировка состояния средствами S3 (без DynamoDB)     |
| `skip_credentials_validation` | не обращаться к STS AWS                                |
| `skip_metadata_api_check`     | не ходить в metadata-сервис EC2                        |
| `skip_region_validation`      | разрешить произвольный region                          |
| `skip_requesting_account_id`  | не запрашивать account id у AWS                        |

- **Адрес** S3-эндпоинта вынесен в `backend.hcl` (`endpoints.s3`) и передаётся при `init`
  через `-backend-config` — его легко переключить на Yandex Object Storage / AWS S3.
- **Креды** (`AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY`) передаются переменными окружения
  и **никогда не хранятся в коде** (в CI — через GitHub Secrets).

## Локальный запуск

```bash
# тот же демон Docker, что использует terraform
export DOCKER_HOST=unix:///var/run/docker.sock

# 1. Поднять S3-хранилище (MinIO) и создать бакет future20-tfstate
docker compose -f docker-compose.minio.yml up -d

# 2. Креды к MinIO (по умолчанию minioadmin/minioadmin)
export AWS_ACCESS_KEY_ID=minioadmin
export AWS_SECRET_ACCESS_KEY=minioadmin

# 3. Init с удалённым backend, plan, apply
terraform init -backend-config=backend.hcl
terraform plan  -var-file=prod.tfvars
terraform apply -var-file=prod.tfvars

# Состояние теперь в MinIO; локального terraform.tfstate нет.
# Консоль MinIO: http://localhost:9001 (minioadmin/minioadmin)
```

Удаление:

```bash
terraform destroy -var-file=prod.tfvars
docker compose -f docker-compose.minio.yml down -v
```

## CI/CD пайплайн (`.github/workflows/terraform.yml`)

Два джоба:

1. **plan** (на PR и push в `main`): `terraform fmt -check` → `init` (backend S3) →
   `validate` → `plan`. Инфраструктура не меняется; план сохраняется артефактом.
2. **apply** (только `workflow_dispatch` — «по кнопке»): выполняется через GitHub
   **Environment `production`** с обязательным **approval** (required reviewers),
   затем `terraform apply`.

Безопасность и изоляция:

- секреты backend — через **GitHub Secrets** (`TFSTATE_ACCESS_KEY`, `TFSTATE_SECRET_KEY`),
  адрес/бакет — через **Repository Variables** (`TFSTATE_ENDPOINT`, `TFSTATE_BUCKET`);
  в коде кред нет;
- токен пайплайна с минимальными правами (`permissions: contents: read`);
- `plan` и `apply` разнесены; реальные изменения — только после ручного подтверждения;
- состояние — в удалённом S3, локально не сохраняется;
- для самодостаточного прогона пайплайн умеет поднять MinIO прямо в раннере
  (если `TFSTATE_ENDPOINT` указывает на `localhost`); для боевого окружения задаются
  Secrets/Variables на внешнее хранилище.

Настройка перед первым запуском в GitHub:

1. **Settings → Environments → New environment → `production`**, включить *Required reviewers*.
2. (Опционально, для внешнего S3) **Settings → Secrets and variables → Actions**: добавить
   secrets `TFSTATE_ACCESS_KEY`, `TFSTATE_SECRET_KEY` и variables `TFSTATE_ENDPOINT`, `TFSTATE_BUCKET`.

## Подтверждение работы (логи)

В каталоге [`logs/`](logs/):

- `minio-up.log` — поднятие MinIO и создание бакета `future20-tfstate`;
- `init.log` — `terraform init` с backend S3 (MinIO);
- `plan.log` / `apply.log` — план и применение (6 ресурсов созданы);
- `state-in-minio.log` — **доказательство**: локального `terraform.tfstate` нет, состояние
  лежит в бакете MinIO (`task2/terraform.tfstate`, ~16 KiB).
