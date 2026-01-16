terraform {
  required_version = ">= 1.11"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "6.9.1"
    }
  }

  backend "local" {}
}

provider "github" {
  owner = var.owner
}
