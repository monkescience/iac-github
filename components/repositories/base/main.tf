locals {
  defaults = yamldecode(file("${var.repos_path}/_defaults.yaml"))

  repo_files = fileset(var.repos_path, "*.yaml")
  repo_configs = {
    for f in local.repo_files :
    trimsuffix(f, ".yaml") => yamldecode(file("${var.repos_path}/${f}"))
    if f != "_defaults.yaml"
  }

  repositories = {
    for name, config in local.repo_configs : name => merge(
      local.defaults,
      config,
      {
        features          = merge(local.defaults.features, lookup(config, "features", {}))
        merge_options     = merge(local.defaults.merge_options, lookup(config, "merge_options", {}))
        branch_protection = merge(local.defaults.branch_protection, lookup(config, "branch_protection", {}))
      }
    )
  }
}

resource "github_repository" "repository" {
  for_each = local.repositories

  name        = each.key
  description = each.value.description
  visibility  = each.value.visibility

  auto_init        = each.value.auto_init
  license_template = each.value.license_template

  homepage_url = each.value.homepage_url
  topics       = each.value.topics
  archived     = each.value.archived

  has_issues      = each.value.features.issues
  has_wiki        = each.value.features.wiki
  has_projects    = each.value.features.projects
  has_discussions = each.value.features.discussions

  vulnerability_alerts = each.value.features.vulnerability_alerts

  allow_merge_commit          = each.value.merge_options.allow_merge_commit
  allow_squash_merge          = each.value.merge_options.allow_squash_merge
  allow_rebase_merge          = each.value.merge_options.allow_rebase_merge
  delete_branch_on_merge      = each.value.merge_options.delete_branch_on_merge
  allow_auto_merge            = each.value.merge_options.allow_auto_merge
  allow_update_branch         = each.value.merge_options.allow_update_branch
  squash_merge_commit_title   = each.value.merge_options.squash_merge_commit_title
  squash_merge_commit_message = each.value.merge_options.squash_merge_commit_message

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_branch_default" "default_branch" {
  for_each = local.repositories

  repository = github_repository.repository[each.key].name
  branch     = each.value.default_branch
}

resource "github_repository_ruleset" "branch_protection" {
  for_each = { for k, v in local.repositories : k => v if v.enable_branch_ruleset }

  name        = "branch-protection"
  repository  = github_repository.repository[each.key].name
  target      = "branch"
  enforcement = "active"

  bypass_actors {
    actor_type  = "OrganizationAdmin"
    actor_id    = 0
    bypass_mode = "always"
  }

  conditions {
    ref_name {
      include = ["~DEFAULT_BRANCH"]
      exclude = []
    }
  }

  rules {
    creation                = false
    deletion                = true
    non_fast_forward        = true
    required_linear_history = true
    required_signatures     = false

    pull_request {
      required_approving_review_count   = each.value.branch_protection.required_approving_review_count
      dismiss_stale_reviews_on_push     = true
      require_code_owner_review         = false
      require_last_push_approval        = false
      required_review_thread_resolution = true
    }

    dynamic "required_status_checks" {
      for_each = length(each.value.branch_protection.required_status_checks) > 0 ? [1] : []
      content {
        strict_required_status_checks_policy = each.value.branch_protection.strict_required_status_checks
        dynamic "required_check" {
          for_each = each.value.branch_protection.required_status_checks
          content {
            context = required_check.value
          }
        }
      }
    }
  }
}

resource "github_repository_ruleset" "conventional_commits" {
  for_each = { for k, v in local.repositories : k => v if v.enable_conventional_commits_ruleset }

  name        = "conventional-commits"
  repository  = github_repository.repository[each.key].name
  target      = "branch"
  enforcement = "active"

  bypass_actors {
    actor_type  = "OrganizationAdmin"
    actor_id    = 0
    bypass_mode = "always"
  }

  conditions {
    ref_name {
      include = ["~DEFAULT_BRANCH"]
      exclude = []
    }
  }

  rules {
    commit_message_pattern {
      operator = "starts_with"
      pattern  = "(feat|fix|docs|style|refactor|test|chore|build|ci|perf|revert)(\\(.+\\))?:"
    }
  }
}

resource "github_repository_ruleset" "branch_naming" {
  for_each = { for k, v in local.repositories : k => v if v.enable_branch_naming_ruleset }

  name        = "branch-naming"
  repository  = github_repository.repository[each.key].name
  target      = "branch"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["~ALL"]
      exclude = ["~DEFAULT_BRANCH", "refs/heads/renovate/*", "refs/heads/release-please--*"]
    }
  }

  rules {
    branch_name_pattern {
      operator = "regex"
      pattern  = "^(feat|fix|chore|docs|refactor|test|ci|build|perf|style|revert)/[a-z0-9-]+$"
    }
  }
}
