variable "owner" {
  type        = string
  description = "GitHub organization or user name."
}

variable "repos_path" {
  type        = string
  description = "Path to the definitions directory containing YAML files."
}
