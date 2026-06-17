# Event Storming «Будущее 2.0»

Целевая событийная архитектура в нотации Event Storming. Условные обозначения:

- 🟦 **Команда** (Command) — намерение пользователя/системы
- 🟧 **Доменное событие** (Domain Event) — факт, опубликованный в шину
- 🟨 **Агрегат** (Aggregate) — где принимается решение и поддерживаются инварианты
- 🟪 **Политика/реакция** (Policy) — «когда произошло событие X → выполнить команду Y»
- 🟩 **Read Model / витрина** — проекция для портала самообслуживания

Полный каталог событий с контрактами — в [`events.md`](./events.md), агрегаты —
в [`aggregates.md`](./aggregates.md).

## Сквозной поток (big picture)

```mermaid
flowchart LR
    classDef cmd fill:#cfe2ff,stroke:#0d6efd,color:#000;
    classDef evt fill:#ffe5b4,stroke:#fd7e14,color:#000;
    classDef agg fill:#fff3cd,stroke:#ffc107,color:#000;
    classDef pol fill:#e7d6ff,stroke:#6f42c1,color:#000;
    classDef rm fill:#d1e7dd,stroke:#198754,color:#000;

    %% Patient Care
    C1["🟦 Зарегистрировать пациента"]:::cmd --> A1{{"🟨 Пациент"}}:::agg
    A1 --> E1["🟧 ЗарегистрированПациент"]:::evt
    E1 --> P1["🟪 Политика: назначить ИИ-исследование"]:::pol

    %% Diagnostics AI
    P1 --> C2["🟦 Запустить ИИ-исследование"]:::cmd
    C2 --> A2{{"🟨 ИсследованиеИИ"}}:::agg
    A2 --> E2["🟧 ПройденоИсследованиеИИ"]:::evt
    E2 --> P2["🟪 Политика: обновить маршрут пациента"]:::pol
    P2 --> C1b["🟦 Обновить маршрут"]:::cmd --> A1

    %% Lending
    C3["🟦 Оформить кредит"]:::cmd --> A3{{"🟨 КредитныйДоговор"}}:::agg
    A3 --> E3["🟧 СозданКредитныйДоговор"]:::evt
    E3 --> P3["🟪 Политика: выставить счёт/график"]:::pol

    %% Payments
    P3 --> C4["🟦 Провести платёж"]:::cmd
    C4 --> A4{{"🟨 Платёж"}}:::agg
    A4 --> E4["🟧 ПлатёжПроведён"]:::evt
    A4 --> E5["🟧 СчётВыставлен"]:::evt

    %% Finance
    E3 --> P4["🟪 Политика: учесть в отчётности"]:::pol
    E4 --> P4
    P4 --> A5{{"🟨 ФинансовыйПериод"}}:::agg
    A5 --> E6["🟧 ОтчётСформирован"]:::evt

    %% Inventory / Pharma / IoT
    C5["🟦 Оформить поставку"]:::cmd --> A6{{"🟨 ПозицияСклада"}}:::agg
    A6 --> E7["🟧 ИзмененОстаток"]:::evt
    E8["🟧 ПоставкаОформлена (Pharma)"]:::evt --> A6
    E9["🟧 ТелеметрияУстройства (IoT)"]:::evt --> A6

    %% Read models -> Self-Service Analytics
    E1 --> RM["🟩 Витрины Self-Service BI"]:::rm
    E2 --> RM
    E3 --> RM
    E4 --> RM
    E6 --> RM
    E7 --> RM
```

## Матрица «событие → источник → подписчики»

| Событие | Источник (Publisher) | Подписчики (Subscribers) |
|---|---|---|
| ЗарегистрированПациент | Patient Care | Diagnostics AI, Self-Service Analytics |
| ПройденоИсследованиеИИ | Diagnostics AI | Patient Care, Self-Service Analytics |
| СозданКредитныйДоговор | Lending | Payments & Billing, Finance, Self-Service Analytics |
| ПлатёжПроведён | Payments & Billing | Finance, Lending, Self-Service Analytics |
| СчётВыставлен | Payments & Billing | Finance, Customer 360 |
| ОтчётСформирован | Finance & Reporting | Self-Service Analytics, Регуляторная отчётность |
| ИзмененОстаток | Inventory & Supply | Finance, Self-Service Analytics |
| ПоставкаОформлена | Pharma Integration | Inventory & Supply |
| ТелеметрияУстройства | Device Telemetry / IoT | Inventory & Supply, Self-Service Analytics |
| КлиентОбновлён | Customer 360 | Все Core-домены |

## Замечания по моделированию

- **Развязка через политики.** Реакции между доменами оформлены как политики
  («когда `ЗарегистрированПациент` → запустить ИИ-исследование»), а не синхронные вызовы —
  это и есть переход от шины Camel/DWH к слабосвязанной событийной модели.
- **Изоляция медданных.** В шину публикуются только факты (регистрация, прохождение
  исследования), без содержимого мед.карт — соответствует ограничению витрины.
- **Read models** питают портал самообслуживания near-real-time, заменяя batch-отчёты DWH.
