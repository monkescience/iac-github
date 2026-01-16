package github

import (
	"iac-github/libraries/mageutil"
	"os"

	"github.com/magefile/mage/mg"
	"github.com/magefile/mage/sh"
)

// Tofu is the namespace for OpenTofu commands for GitHub repos.
type Tofu mg.Namespace

func getOwner() string {
	owner := mageutil.GetEnvValueOrWaitForInput("OWNER", "monkescience")
	os.Setenv("GITHUB_OWNER", owner)

	return owner
}

// Init initializes the tofu project.
func (Tofu) Init() error {
	owner := getOwner()

	return sh.RunV("tofu",
		"-chdir="+owner,
		"init",
	)
}

// Validate validates the tofu configuration.
func (Tofu) Validate() error {
	mg.Deps(Tofu.Init)

	owner := getOwner()

	return sh.RunV("tofu",
		"-chdir="+owner,
		"validate",
	)
}

// Plan creates an execution plan.
func (Tofu) Plan() error {
	mg.Deps(Tofu.Init)

	owner := getOwner()

	return sh.RunV("tofu",
		"-chdir="+owner,
		"plan",
		"-out=terraform.tfplan",
		"-var=owner="+owner,
	)
}

// Plandestroy creates an execution plan to destroy.
func (Tofu) Plandestroy() error {
	mg.Deps(Tofu.Init)

	owner := getOwner()

	return sh.RunV("tofu",
		"-chdir="+owner,
		"plan",
		"-out=terraform.tfplan",
		"-var=owner="+owner,
		"-destroy",
	)
}

// Show shows the planned changes.
func (Tofu) Show() error {
	owner := getOwner()

	return sh.RunV("tofu",
		"-chdir="+owner,
		"show",
		"terraform.tfplan",
	)
}

// Apply applies the planned changes.
func (Tofu) Apply() error {
	owner := getOwner()

	return sh.RunV("tofu",
		"-chdir="+owner,
		"apply",
		"terraform.tfplan",
	)
}

// Fmt formats the terraform files.
func (Tofu) Fmt() error {
	return sh.RunV("tofu", "fmt", "-recursive", "../..")
}
