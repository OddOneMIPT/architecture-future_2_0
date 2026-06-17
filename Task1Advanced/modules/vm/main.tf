###############################################################################
# Модуль vm: универсальная "виртуальная машина", смоделированная Docker-контейнером.
#   - Количество ядер  -> cpu_shares (+ метка cores)
#   - Объём RAM        -> memory (МБ)
#   - Подключаемый диск -> docker_volume, смонтированный в контейнер
#   - Subnet ID        -> docker_network (передаётся снаружи)
#   - SSH-ключ         -> env SSH_PUBLIC_KEY + запись в подключённый диск
###############################################################################

locals {
  # Общие метки для всех ресурсов ВМ.
  base_labels = merge(
    {
      "managed-by"   = "terraform"
      "module"       = "vm"
      "cores"        = tostring(var.cores)
      "memory_mb"    = tostring(var.memory_mb)
      "disk_size_gb" = tostring(var.disk_size_gb)
    },
    var.labels,
  )
}

# Базовый образ ВМ.
resource "docker_image" "this" {
  name         = var.image
  keep_locally = true
}

# Подключаемый диск ВМ (по одному на каждую ВМ).
resource "docker_volume" "disk" {
  count = var.vm_count
  name  = "${var.vm_name}-${count.index}-disk"

  labels {
    label = "managed-by"
    value = "terraform"
  }
  labels {
    label = "disk_size_gb"
    value = tostring(var.disk_size_gb)
  }
}

# Сама ВМ (контейнер).
resource "docker_container" "vm" {
  count = var.vm_count
  name  = "${var.vm_name}-${count.index}"
  image = docker_image.this.image_id

  # Ресурсы ВМ.
  memory     = var.memory_mb    # RAM, МБ
  cpu_shares = var.cores * 1024 # количество ядер -> относительный вес CPU

  restart = "unless-stopped"

  # Подключение к сети (subnet), которую создаёт окружение.
  networks_advanced {
    name = var.subnet_id
  }

  # Подключаемый диск.
  volumes {
    volume_name    = docker_volume.disk[count.index].name
    container_path = var.disk_mount_path
  }

  # SSH-ключ прокидывается в ВМ через окружение (без хардкода в модуле).
  env = [
    "SSH_PUBLIC_KEY=${var.ssh_public_key}",
    "VM_NAME=${var.vm_name}-${count.index}",
  ]

  # Сохраняем публичный ключ на подключённый диск (имитация ~/.ssh/authorized_keys).
  command = [
    "/bin/sh", "-c",
    "mkdir -p ${var.disk_mount_path}/.ssh && printf '%s\\n' \"$SSH_PUBLIC_KEY\" > ${var.disk_mount_path}/.ssh/authorized_keys && chmod 600 ${var.disk_mount_path}/.ssh/authorized_keys && exec nginx -g 'daemon off;'",
  ]

  # Публикация порта сервиса ВМ на хост (опционально). exposed_port = 0 -> не публикуется.
  # internal_port — порт сервиса внутри ВМ, exposed_port(+индекс) — порт на хосте.
  dynamic "ports" {
    for_each = var.exposed_port > 0 ? [1] : []
    content {
      internal = var.internal_port
      external = var.exposed_port + count.index
    }
  }

  # Метки ВМ.
  dynamic "labels" {
    for_each = local.base_labels
    content {
      label = labels.key
      value = labels.value
    }
  }
}
