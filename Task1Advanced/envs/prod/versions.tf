terraform {
  required_version = ">= 1.6.0"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }

  # Task1: состояние хранится локально (удалённый backend — в Task2Advanced).
  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "docker" {}
