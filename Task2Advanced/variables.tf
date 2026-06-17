variable "environment" {
  description = "Имя окружения."
  type        = string
  default     = "prod"
}

variable "subnet_cidr" {
  description = "CIDR-подсеть для сети окружения."
  type        = string
}

variable "vm_name" {
  description = "Базовое имя ВМ."
  type        = string
}

variable "vm_count" {
  description = "Количество ВМ."
  type        = number
}

variable "cores" {
  description = "Количество ядер CPU на ВМ."
  type        = number
}

variable "memory_mb" {
  description = "Объём RAM на ВМ (МБ)."
  type        = number
}

variable "disk_size_gb" {
  description = "Размер подключаемого диска (ГБ)."
  type        = number
}

variable "exposed_port" {
  description = "Публикуемый порт ВМ (0 — не публиковать)."
  type        = number
  default     = 0
}

variable "ssh_public_key" {
  description = "Публичный SSH-ключ для доступа к ВМ."
  type        = string
  sensitive   = true
}
