# Task1Advanced — Модульная инфраструктура для нескольких сред

Переиспользуемый Terraform-модуль ВМ и три окружения (dev/stage/prod), каждое со своей
конфигурацией через отдельный `*.tfvars`.

> «ВМ» смоделирована Docker-контейнером (провайдер `kreuzwerker/docker`), чтобы решение
> **реально разворачивалось локально** на любой машине с Docker — без облачных кредитов и
> без KVM/libvirt. Маппинг параметров ВМ на Docker описан в [`modules/vm/README.md`](modules/vm/README.md).

## Структура

```
Task1Advanced/
├── modules/
│   └── vm/                  # переиспользуемый модуль ВМ (без значений окружений)
│       ├── main.tf          # ВМ (container) + диск (volume) + сеть + SSH-ключ
│       ├── variables.tf     # входные параметры
│       ├── outputs.tf       # id ВМ, ip, имя, id диска, сеть
│       ├── versions.tf
│       └── README.md
├── envs/                    # окружения, каждое вызывает модуль с разными параметрами
│   ├── dev/   { main.tf, variables.tf, outputs.tf, versions.tf, dev.tfvars }
│   ├── stage/ { ..., stage.tfvars }
│   └── prod/  { ..., prod.tfvars }
└── logs/                    # логи реального развёртывания (см. ниже)
```

## Конфигурации окружений

| Окружение | ВМ | Ядра | RAM    | Диск  | Subnet           | Порт на хосте       |
|-----------|----|------|--------|-------|------------------|---------------------|
| dev       | 1  | 1    | 512 МБ | 10 ГБ | 172.30.10.0/24   | 18080               |
| stage     | 2  | 2    | 1 ГБ   | 20 ГБ | 172.30.20.0/24   | 18090–18091         |
| prod      | 3  | 4    | 2 ГБ   | 40 ГБ | 172.30.30.0/24   | 18100–18102         |

Один и тот же модуль `modules/vm` переиспользуется во всех трёх окружениях — различаются
только значения в `*.tfvars`.

## Предварительные требования

- Terraform >= 1.6 (`brew install hashicorp/tap/terraform`)
- Docker (демон запущен)

## Как запускать

Для каждого окружения — из его директории:

```bash
cd envs/dev
terraform init
terraform apply -var-file=dev.tfvars
```

Аналогично для `stage` (`-var-file=stage.tfvars`) и `prod` (`-var-file=prod.tfvars`).

Полезные команды:

```bash
terraform output            # выходы (id, ip, имена ВМ, диски)
terraform destroy -var-file=dev.tfvars   # удалить окружение
```

### Замечание про Docker-демон (важно для проверки)

Провайдер Terraform подключается к стандартному сокету Docker
(`unix:///var/run/docker.sock`). Если ваш `docker` CLI настроен на другой context
(например, Lima/Colima), укажите тот же сокет для проверки:

```bash
export DOCKER_HOST=unix:///var/run/docker.sock
docker ps --filter name=future20-
```

## Подтверждение работы (логи)

В каталоге [`logs/`](logs/) — вывод реального развёртывания:

- `apply-dev.log`, `apply-stage.log`, `apply-prod.log` — вывод `terraform apply` по каждому окружению;
- `outputs-dev.log`, `outputs-stage.log`, `outputs-prod.log` — `terraform output`;
- `docker-ps.log` — `docker ps` всех 6 ВМ + таблица ресурсов (RAM/ядра/сеть/IP), HTTP-проверка
  опубликованных портов (все `HTTP 200`) и проброшенный SSH-ключ.

Кратко из `docker-ps.log` — разные конфигурации применились корректно:

```
name                  RAM_MB    cpu_shares   network                IP
future20-dev-vm-0     512       1024         future20-dev-subnet    172.30.10.2
future20-stage-vm-0   1024      2048         future20-stage-subnet  172.30.20.3
future20-stage-vm-1   1024      2048         future20-stage-subnet  172.30.20.2
future20-prod-vm-0    2048      4096         future20-prod-subnet   172.30.30.3
future20-prod-vm-1    2048      4096         future20-prod-subnet   172.30.30.4
future20-prod-vm-2    2048      4096         future20-prod-subnet   172.30.30.2
```
