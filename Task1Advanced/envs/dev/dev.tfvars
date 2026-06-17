# Конфигурация окружения DEV — минимальные ресурсы.
environment  = "dev"
subnet_cidr  = "172.30.10.0/24"
vm_name      = "future20-dev-vm"
vm_count     = 1
image        = "nginx:alpine"
cores        = 1
memory_mb    = 512
disk_size_gb = 10
exposed_port = 18080

ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMZtfTD8uo9RL+rtBgxvSmV2SAPvMJD67q3tEuFqFi08 future20-demo"
