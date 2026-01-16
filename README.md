# iac-github

Infrastructure as Code for GitHub resources using OpenTofu.

## Prerequisites

- [OpenTofu](https://opentofu.org/) (or Terraform)
- [Mage](https://magefile.org/)
- Go 1.24+
- `GITHUB_TOKEN` environment variable with appropriate permissions

## Usage

```bash
cd components/repositories/magefiles

# List available targets
mage -l

# Initialize and plan
OWNER=monkescience mage tofu:plan

# Apply changes
mage tofu:apply
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `OWNER` | `monkescience` | GitHub organization name |
| `GITHUB_TOKEN` | - | GitHub personal access token |

## Structure

```
components/
  repositories/         # GitHub repository management
    base/               # Shared Terraform configuration
    <owner>/            # Owner-specific configuration (e.g. monkescience/)
      definitions/      # Repository definition YAML files
    magefiles/          # Mage build targets
libraries/
  mageutil/             # Shared Mage utilities
```