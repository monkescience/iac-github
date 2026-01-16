module "base" {
  source = "../base"

  owner      = var.owner
  repos_path = "${path.module}/definitions"
}
