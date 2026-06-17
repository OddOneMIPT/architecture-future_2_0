terraform {
  required_version = ">= 1.10.0" # use_lockfile (S3-native locking) доступен с 1.10

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}
