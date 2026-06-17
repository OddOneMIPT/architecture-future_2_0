###############################################################################
# Task2: тот же модуль ВМ, что и в Task1, но с УДАЛЁННЫМ состоянием (S3/MinIO).
# Переиспользование модуля демонстрируется через относительный source.
###############################################################################

resource "docker_network" "subnet" {
  name   = "future20-${var.environment}-subnet-rs"
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
  source = "../Task1Advanced/modules/vm"

  vm_name        = var.vm_name
  vm_count       = var.vm_count
  cores          = var.cores
  memory_mb      = var.memory_mb
  disk_size_gb   = var.disk_size_gb
  exposed_port   = var.exposed_port
  subnet_id      = docker_network.subnet.name
  ssh_public_key = var.ssh_public_key

  labels = {
    environment = var.environment
    state       = "remote-s3"
  }
}

output "environment" {
  value = var.environment
}

output "vm_names" {
  value = module.vm.vm_names
}

output "vm_ip_addresses" {
  value = module.vm.ip_addresses
}

output "subnet" {
  value = docker_network.subnet.name
}
