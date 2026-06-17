# Каталог доменных событий «Будущее 2.0»

Каталог событий целевой событийной платформы. Для каждого события: **контекст-источник**,
**семантика**, **минимальный контракт** (обязательные поля) и **подписчики**.

## Конвенции контрактов

Все события несут стандартный конверт (envelope):

| Поле | Тип | Назначение |
|---|---|---|
| `event_id` | UUID | Уникальный идентификатор события (идемпотентность) |
| `event_type` | string | Имя события + версия, напр. `lending.LoanCreated.v1` |
| `occurred_at` | timestamp (ISO-8601) | Время факта |
| `producer` | string | Контекст-источник |
| `correlation_id` | UUID | Сквозная трассировка |
| `payload` | object | Полезная нагрузка (см. ниже) |

Схемы версионируются в **Schema Registry** (обратная совместимость); невалидные события → **DLQ**.

---

## Lending

### СозданКредитныйДоговор — `lending.LoanCreated.v1`
- **Источник:** Lending
- **Семантика:** оформлен новый кредитный договор (агрегат `КредитныйДоговор` перешёл в `Активен`).
- **Контракт payload:** `loan_id`, `customer_id`, `amount`, `currency`, `rate`, `term_months`, `opened_at`
- **Подписчики:** Payments & Billing (график/счета), Finance & Reporting (учёт), Self-Service Analytics

### КредитПогашен — `lending.LoanRepaid.v1`
- **Источник:** Lending · **Семантика:** договор полностью погашен.
- **Payload:** `loan_id`, `customer_id`, `repaid_at`, `total_paid`
- **Подписчики:** Finance, Self-Service Analytics

## Patient Care

### ЗарегистрированПациент — `patient.PatientRegistered.v1`
- **Источник:** Patient Care
- **Семантика:** зарегистрирован новый пациент (без содержимого мед.карты).
- **Payload:** `patient_id`, `customer_id`, `clinic_id`, `registered_at` *(никаких медданных)*
- **Подписчики:** Diagnostics AI (назначение исследования), Self-Service Analytics

## Diagnostics AI

### ПройденоИсследованиеИИ — `diagnostics.AiStudyCompleted.v1`
- **Источник:** Diagnostics AI
- **Семантика:** ИИ-исследование завершено; публикуется **факт и статус**, без заключения.
- **Payload:** `study_id`, `patient_id`, `model`, `status`, `completed_at` *(без содержимого заключения)*
- **Подписчики:** Patient Care (обновление маршрута), Self-Service Analytics

## Payments & Billing

### ПлатёжПроведён — `payments.PaymentCompleted.v1`
- **Источник:** Payments & Billing · **Семантика:** платёж успешно проведён.
- **Payload:** `payment_id`, `customer_id`, `amount`, `currency`, `method`, `loan_id?`, `invoice_id?`, `completed_at`
- **Подписчики:** Finance, Lending, Self-Service Analytics

### СчётВыставлен — `billing.InvoiceIssued.v1`
- **Источник:** Payments & Billing · **Семантика:** клиенту выставлен счёт.
- **Payload:** `invoice_id`, `customer_id`, `amount`, `currency`, `due_date`, `issued_at`
- **Подписчики:** Finance, Customer 360

## Finance & Reporting

### ОтчётСформирован — `finance.ReportGenerated.v1`
- **Источник:** Finance & Reporting · **Семантика:** сформирован отчёт за закрытый период.
- **Payload:** `report_id`, `period_id`, `type`, `generated_at`
- **Подписчики:** Self-Service Analytics, Регуляторная отчётность

## Inventory & Supply

### ИзмененОстаток — `inventory.StockChanged.v1`
- **Источник:** Inventory & Supply · **Семантика:** изменился остаток позиции.
- **Payload:** `sku_id`, `location_id`, `delta`, `balance`, `changed_at`
- **Подписчики:** Finance, Self-Service Analytics

## Pharma Integration (новый домен)

### ПоставкаОформлена — `pharma.SupplyOrdered.v1`
- **Источник:** Pharma Integration · **Семантика:** оформлена поставка препаратов.
- **Payload:** `supply_id`, `supplier_id`, `items[]`, `eta`, `ordered_at`
- **Подписчики:** Inventory & Supply

## Device Telemetry / IoT (новый домен)

### ТелеметрияУстройства — `iot.DeviceTelemetry.v1`
- **Источник:** Device Telemetry / IoT · **Семантика:** телеметрия медоборудования.
- **Payload:** `device_id`, `metric`, `value`, `unit`, `measured_at`
- **Подписчики:** Inventory & Supply (состояние оборудования), Self-Service Analytics

## Customer 360

### КлиентОбновлён — `customer.CustomerUpdated.v1`
- **Источник:** Customer 360 · **Семантика:** изменён профиль клиента (Published Language).
- **Payload:** `customer_id`, `changed_fields[]`, `updated_at`
- **Подписчики:** все Core-домены

---

## Сводная таблица событий

| Событие | event_type | Источник | Подписчики |
|---|---|---|---|
| Создан кредитный договор | lending.LoanCreated.v1 | Lending | Payments, Finance, Analytics |
| Кредит погашен | lending.LoanRepaid.v1 | Lending | Finance, Analytics |
| Зарегистрирован новый пациент | patient.PatientRegistered.v1 | Patient Care | Diagnostics AI, Analytics |
| Пройдено исследование ИИ | diagnostics.AiStudyCompleted.v1 | Diagnostics AI | Patient Care, Analytics |
| Платёж проведён | payments.PaymentCompleted.v1 | Payments | Finance, Lending, Analytics |
| Счёт выставлен | billing.InvoiceIssued.v1 | Payments | Finance, Customer 360 |
| Отчёт сформирован | finance.ReportGenerated.v1 | Finance | Analytics, Регулятор |
| Изменён остаток | inventory.StockChanged.v1 | Inventory | Finance, Analytics |
| Поставка оформлена | pharma.SupplyOrdered.v1 | Pharma | Inventory |
| Телеметрия устройства | iot.DeviceTelemetry.v1 | IoT | Inventory, Analytics |
| Клиент обновлён | customer.CustomerUpdated.v1 | Customer 360 | Все Core-домены |
