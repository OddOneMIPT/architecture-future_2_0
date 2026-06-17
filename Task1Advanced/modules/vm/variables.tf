###############################################################################
# Входные параметры модуля vm.
# Модуль НЕ содержит захардкоженных значений окружений — всё задаётся снаружи.
###############################################################################

variable "vm_name" {
  description = "Базовое имя ВМ (контейнера). При vm_count > 1 к имени добавляется индекс."
  type        = string

  validation {
    condition     = length(var.vm_name) > 0
    error_message = "vm_name не может быть пустым."
  }
}

variable "vm_count" {
  description = "Количество одинаковых ВМ, которое нужно создать."
  type        = number
  default     = 1

  validation {
    condition     = var.vm_count >= 1
    error_message = "vm_count должен быть >= 1."
  }
}

variable "image" {
  description = "Docker-образ, используемый как базовый образ ВМ."
  type        = string
  default     = "nginx:alpine"
}

variable "cores" {
  description = "Количество выделяемых ядер CPU."
  type        = number

  validation {
    condition     = var.cores >= 1
    error_message = "cores должен быть >= 1."
  }
}

variable "memory_mb" {
  description = "Объём оперативной памяти (RAM) в мегабайтах."
  type        = number

  validation {
    condition     = var.memory_mb >= 64
    error_message = "memory_mb должен быть >= 64 МБ."
  }
}

variable "disk_size_gb" {
  description = "Заявленный размер подключаемого диска в ГБ (фиксируется в метках тома)."
  type        = number
  default     = 10
}

variable "disk_mount_path" {
  description = "Путь монтирования подключаемого диска внутри ВМ."
  type        = string
  default     = "/data"
}

variable "subnet_id" {
  description = "ID/имя сети (subnet), к которой подключается ВМ. Создаётся на уровне окружения."
  type        = string
}

variable "ssh_public_key" {
  description = "Публичный SSH-ключ для доступа к ВМ. Прокидывается внутрь без хардкода в модуле."
  type        = string
  sensitive   = true
}

variable "internal_port" {
  description = "Порт сервиса внутри ВМ (для образа по умолчанию nginx — 80)."
  type        = number
  default     = 80
}

variable "exposed_port" {
  description = "Порт на хосте, на который публикуется internal_port. 0 — не публиковать."
  type        = number
  default     = 0
}

variable "labels" {
  description = "Дополнительные метки (теги) для ВМ."
  type        = map(string)
  default     = {}
}
