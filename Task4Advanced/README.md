# Task4Advanced — DDD, Bounded Contexts и Event Storming

Задание 4: разделить систему на домены по **Domain-Driven Design**, определить bounded contexts,
описать ключевые **агрегаты** и **события**, построить **Event Storming** и обосновать переход на
событийную интеграцию вместо Camel + DWH.

## Состав

| Файл | Содержание |
|------|------------|
| [`bounded-contexts.md`](./bounded-contexts.md) | Декомпозиция на домены, классификация поддоменов (Core/Supporting/Generic), Context Map и стратегические паттерны (OHS/PL, ACL, C/S). |
| [`event-storming.md`](./event-storming.md) | Event Storming-диаграмма (команды → агрегаты → события → политики → read models), матрица «событие → источник → подписчики». |
| [`aggregates.md`](./aggregates.md) | Ключевые агрегаты: границы, инварианты, идентификаторы. |
| [`events.md`](./events.md) | Каталог доменных событий: источник, семантика, минимальный контракт, подписчики. |
| [`justification.md`](./justification.md) | Обоснование событийного подхода vs Camel/DWH (гибкость, масштабируемость, скорость, стоимость). |

## Домены (bounded contexts)

**Core:** Patient Care · Diagnostics AI · Lending · Payments & Billing
**Supporting:** Customer 360 · Finance & Reporting · HR · Inventory & Supply · Pharma · IoT
**Platform/Legacy:** Self-Service Analytics Platform · Legacy Bridge (ACL к DWH/Camel)

## Согласованность с другими заданиями
Имена доменов, агрегатов и событий совпадают с C4-моделью в
[`../Task3Advanced/`](../Task3Advanced/) и роадмапом в [`../Task5Advanced/`](../Task5Advanced/).

