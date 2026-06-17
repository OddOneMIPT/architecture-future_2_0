###############################################################################
# Окружение: создаёт собственную сеть (subnet) и разворачивает ВМ через модуль.
# Один и тот же модуль ../../modules/vm используется во всех окружениях.
###############################################################################

# Сеть окружения (subnet), ID которой передаётся в модуль.
resource "docker_network" "subnet" {
  name   = "future20-${var.environment}-subnet"
  driver = "bridge"

  ipam_config {
    subnet = var.subnet_cidr
  }

  labels {
    label = "environment"
    value = var.environment
  }
}

module "vm" {
  source = "../../modules/vm"

  vm_name        = var.vm_name
  vm_count       = var.vm_count
  image          = var.image
  cores          = var.cores
  memory_mb      = var.memory_mb
  disk_size_gb   = var.disk_size_gb
  exposed_port   = var.exposed_port
  subnet_id      = docker_network.subnet.name
  ssh_public_key = var.ssh_public_key

  labels = {
    environment = var.environment
  }
}
