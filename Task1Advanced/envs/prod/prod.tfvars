# Конфигурация окружения PROD — максимальные ресурсы, три ВМ.
environment  = "prod"
subnet_cidr  = "172.30.30.0/24"
vm_name      = "future20-prod-vm"
vm_count     = 3
image        = "nginx:alpine"
cores        = 4
memory_mb    = 2048
disk_size_gb = 40
exposed_port = 18100

ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMZtfTD8uo9RL+rtBgxvSmV2SAPvMJD67q3tEuFqFi08 future20-demo"
