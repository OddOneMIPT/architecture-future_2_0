# Модуль `vm`

Универсальный переиспользуемый Terraform-модуль «виртуальной машины». Чтобы решение
разворачивалось **локально** (без облачных кредов и без KVM/libvirt на macOS), ВМ
смоделирована Docker-контейнером через провайдер
[`kreuzwerker/docker`](https://registry.terraform.io/providers/kreuzwerker/docker/latest).
Один и тот же модуль используется во всех окружениях (dev/stage/prod) и в Task2Advanced.

## Что делает

Для каждой ВМ модуль создаёт:

- **ВМ** (`docker_container`) с заданными ресурсами;
- **подключаемый диск** (`docker_volume`), смонтированный в ВМ по пути `disk_mount_path`;
- **проброс SSH-ключа** внутрь ВМ (в `<disk>/.ssh/authorized_keys`);
- (опционально) **публикацию порта** сервиса на хост.

ВМ подключается к **сети (subnet)**, которая создаётся снаружи (на уровне окружения) и
передаётся в модуль как `subnet_id`. Внутри модуля **нет захардкоженных значений
окружений** — всё параметризовано.

Маппинг «параметры ВМ → Docker»:

| Параметр задания   | Переменная       | Реализация в Docker                     |
|--------------------|------------------|-----------------------------------------|
| Количество ядер    | `cores`          | `cpu_shares = cores * 1024` + метка     |
| Объём RAM          | `memory_mb`      | `memory` (МБ)                           |
| Подключаемый диск  | `disk_size_gb`   | `docker_volume`, монтируется в `/data`  |
| Subnet ID          | `subnet_id`      | `networks_advanced { name = subnet_id }`|
| SSH-ключ           | `ssh_public_key` | env `SSH_PUBLIC_KEY` + authorized_keys  |

## Входные параметры (`variables.tf`)

| Имя              | Тип           | Обяз. | По умолчанию  | Описание                                            |
|------------------|---------------|-------|---------------|-----------------------------------------------------|
| `vm_name`        | string        | да    | —             | Базовое имя ВМ (к нему добавляется индекс)          |
| `vm_count`       | number        | нет   | `1`           | Количество одинаковых ВМ                             |
| `image`          | string        | нет   | `nginx:alpine`| Базовый образ ВМ                                    |
| `cores`          | number        | да    | —             | Количество ядер CPU                                 |
| `memory_mb`      | number        | да    | —             | RAM в МБ                                            |
| `disk_size_gb`   | number        | нет   | `10`          | Заявленный размер диска (метка тома)                |
| `disk_mount_path`| string        | нет   | `/data`       | Путь монтирования диска                             |
| `subnet_id`      | string        | да    | —             | Имя/ID сети, создаётся в окружении                  |
| `ssh_public_key` | string        | да    | —             | Публичный SSH-ключ (sensitive)                      |
| `internal_port`  | number        | нет   | `80`          | Порт сервиса внутри ВМ                               |
| `exposed_port`   | number        | нет   | `0`           | Порт на хосте (`0` — не публиковать)                |
| `labels`         | map(string)   | нет   | `{}`          | Дополнительные метки                                |

## Выходы (`outputs.tf`)

| Имя             | Описание                              |
|-----------------|---------------------------------------|
| `vm_ids`        | ID созданных ВМ                       |
| `vm_names`      | Имена ВМ                              |
| `ip_addresses`  | IP-адреса ВМ в subnet                 |
| `disk_ids`      | ID подключённых дисков                |
| `disk_names`    | Имена подключённых дисков             |
| `subnet_id`     | Сеть, к которой подключены ВМ         |
| `image_id`      | ID базового образа                    |

## Как использовать

Модуль не запускается напрямую — он вызывается из окружения. Пример вызова:

```hcl
resource "docker_network" "subnet" {
  name = "future20-dev-subnet"
  ipam_config { subnet = "172.30.10.0/24" }
}

module "vm" {
  source = "../../modules/vm"

  vm_name        = "future20-dev-vm"
  vm_count       = 1
  cores          = 1
  memory_mb      = 512
  disk_size_gb   = 10
  exposed_port   = 18080
  subnet_id      = docker_network.subnet.name
  ssh_public_key = var.ssh_public_key
}
```

Запуск конкретного окружения — см. [../../README.md](../../README.md):

```bash
cd envs/dev
terraform init
terraform apply -var-file=dev.tfvars
```

## Требования

- Terraform >= 1.6
- Docker (демон должен быть запущен)
