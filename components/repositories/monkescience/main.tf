module "base" {
  source = "../base"

  repos_path = "${path.module}/definitions"
}
