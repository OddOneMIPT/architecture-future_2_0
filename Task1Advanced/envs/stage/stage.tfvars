# Конфигурация окружения STAGE — средние ресурсы, две ВМ.
environment  = "stage"
subnet_cidr  = "172.30.20.0/24"
vm_name      = "future20-stage-vm"
vm_count     = 2
image        = "nginx:alpine"
cores        = 2
memory_mb    = 1024
disk_size_gb = 20
exposed_port = 18090

ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMZtfTD8uo9RL+rtBgxvSmV2SAPvMJD67q3tEuFqFi08 future20-demo"
