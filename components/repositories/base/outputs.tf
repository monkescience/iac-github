output "repositories" {
  value = {
    for k, v in github_repository.repository : k => {
      name      = v.name
      full_name = v.full_name
      html_url  = v.html_url
    }
  }
  description = "Map of created repositories."
}
