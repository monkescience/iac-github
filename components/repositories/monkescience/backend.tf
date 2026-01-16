terraform {
  backend "local" {}
}

provider "github" {}

data "github_organization" "owner" {
  name                  = var.owner
  ignore_archived_repos = true
  summary_only          = true
}
