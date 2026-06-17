# architecture-future_2_0

## Terraform (Task1 + Task2)

«ВМ» моделируется Docker-контейнером (провайдер `kreuzwerker/docker`), чтобы инфраструктура
**реально разворачивалась локально** на любой машине с Docker — без облачных кредитов и без
KVM/libvirt. В каждой задаче есть каталог `logs/` с выводом реального `terraform apply`,
`docker ps` и подтверждением удалённого состояния.

Требования: Terraform >= 1.10 (`brew install hashicorp/tap/terraform`), Docker.

Быстрый старт:

```bash
# Task1 — окружение dev
cd Task1Advanced/envs/dev && terraform init && terraform apply -var-file=dev.tfvars

# Task2 — удалённое состояние в MinIO
cd Task2Advanced && docker compose -f docker-compose.minio.yml up -d
export AWS_ACCESS_KEY_ID=minioadmin AWS_SECRET_ACCESS_KEY=minioadmin
terraform init -backend-config=backend.hcl && terraform apply -var-file=prod.tfvars
```

Подробности — в README соответствующих директорий:
[Task1Advanced](Task1Advanced/README.md) · [Task2Advanced](Task2Advanced/README.md).

## Архитектурные задания (Task3–5)

Задания 3–5 — документально-архитектурные: проектирование целевой событийной платформы
«Будущего 2.0» (Data Mesh, портал самообслуживания, вывод легаси DWH/PowerBuilder/Camel) на
горизонт 3 лет.

- **[Task3Advanced](Task3Advanced/README.md)** — C4-модель (Context/Container/Component),
  карта рисков (вероятность × влияние) и план управления (технические vs управленческие меры).
- **[Task4Advanced](Task4Advanced/README.md)** — DDD: bounded contexts, Event Storming, агрегаты,
  каталог событий и обоснование событийного подхода vs Camel/DWH.
- **[Task5Advanced](Task5Advanced/README.md)** — расширенный техрадар (Adopt/Trial/Assess/Hold),
  TCO-анализ (текущая vs целевая, 3 года) и роадмап внедрения Data Mesh.
