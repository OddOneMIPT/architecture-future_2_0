###############################################################################
# Полезные выходы модуля vm.
###############################################################################

output "vm_ids" {
  description = "ID созданных ВМ (контейнеров)."
  value       = docker_container.vm[*].id
}

output "vm_names" {
  description = "Имена созданных ВМ."
  value       = docker_container.vm[*].name
}

output "ip_addresses" {
  description = "IP-адреса ВМ в подключённой сети (subnet)."
  value       = [for vm in docker_container.vm : one(vm.network_data[*].ip_address)]
}

output "disk_ids" {
  description = "ID подключаемых дисков (томов)."
  value       = docker_volume.disk[*].id
}

output "disk_names" {
  description = "Имена подключаемых дисков (томов)."
  value       = docker_volume.disk[*].name
}

output "subnet_id" {
  description = "ID/имя сети (subnet), к которой подключены ВМ."
  value       = var.subnet_id
}

output "image_id" {
  description = "ID базового образа ВМ."
  value       = docker_image.this.image_id
}
