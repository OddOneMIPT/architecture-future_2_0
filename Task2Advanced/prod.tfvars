# Пример конфигурации окружения для Task2 (удалённое состояние в MinIO).
environment  = "prod"
subnet_cidr  = "172.31.30.0/24"
vm_name      = "future20-rs-vm"
vm_count     = 2
cores        = 2
memory_mb    = 1024
disk_size_gb = 20
exposed_port = 18200

ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMZtfTD8uo9RL+rtBgxvSmV2SAPvMJD67q3tEuFqFi08 future20-demo"
