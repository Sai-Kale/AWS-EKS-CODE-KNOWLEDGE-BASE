# Contributing Guidelines

This document highlights the process to contribute to a Terraform module. There are a set of code quality, Terraform, and project standards to follow in order to contribute to the project sucessfully.

[[_TOC_]]

## Policies & Standards

Please visit [SpecFlow/Terraform Modules](https://gitlab.spectrumflow.net/specflow/terraform#standards) in GitLab to find the latest Code Quality, Terraform, and Project Standards. A periodic review will be performed to ensure that all projects are compliant.

## Setup

Documentation is both programmatically and conventionally generated. It is highly recommended that you complete the Setup steps before starting work on a module.

<details>
<summary><strong>Pre-Commit Hooks</strong></summary>

- *Only applicable for local development purposes.*

**Installation**

```bash
brew install terraform-docs
brew install pre-commit
```

**Usage**

```bash
pre-commit install
```

</details>

## Contibuting Process

The process below shows how to contribute to a Terraform module and the process to test the modules.

1. Create a new branch from `develop` with the prefix of `fix/` or `feature/`.
   a. This will automatically kick off a pipeline to release your module with the following version scheme: `<LATEST_VERSION>-<fix|feature>.<SHORT SHA>`
   b. For example, a branch called `fix/adjust-terraform-version` will release a module versioned as `1.0.0-fix.7h2gd629`
2. Commit your proposed changes to the branch you have created. Every commit will get tagged and released with the commit short SHA.
   a. You can utilize the released pre-release module in your consumer pipeline to test your changes.
3. Once you have completed your changes, raise an MR to the `develop` branch with the details of your changes.
   a. A module will be released with the following version scheme: `<LATEST_VERSION>-<develop>.<SHORT SHA>`
4. Once the `CODEOWNERS` are satisified with the changes in `develop`, a merge request should be raised with the following format:
   - NAME: `fix|feature: <Description>` (example: feature: Implemented New AWS EC2 Resources)
   - DESCRIPTION: `The following merge request introduces...`
   - Delete Source Branch: `FALSE`
   - Squash Commits: `TRUE`

When the `main` branch receives a commit with the following format, the version number will be incremented accordingly.

- Commits starting with `fix:` will release a new patch version. (e.g. 1.0.0 => 1.0.1)
- Commits starting with `feature:` will release a new minor version (e.g. 1.0.0 => 1.1.0)
- Commits starting with `BREAKING CHANGE:` will release a new major version (e.g. 1.0.0 => 2.0.0)

If the commits in `main` do not match this format, no version will be released and the pipeline will fail.