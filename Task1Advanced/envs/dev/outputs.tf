output "environment" {
  description = "Имя окружения."
  value       = var.environment
}

output "subnet" {
  description = "Сеть (subnet) окружения."
  value       = docker_network.subnet.name
}

output "vm_ids" {
  description = "ID созданных ВМ."
  value       = module.vm.vm_ids
}

output "vm_names" {
  description = "Имена созданных ВМ."
  value       = module.vm.vm_names
}

output "vm_ip_addresses" {
  description = "IP-адреса ВМ."
  value       = module.vm.ip_addresses
}

output "vm_disk_names" {
  description = "Имена подключённых дисков."
  value       = module.vm.disk_names
}
