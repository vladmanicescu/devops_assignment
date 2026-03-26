# Contributing

Thanks for your interest in this project.

## How to contribute

1. **Fork** the repository and create a **branch** for your change.
2. Keep changes **focused** — one logical fix or feature per pull request.
3. Run checks locally when relevant:
   - `pocket validate` with a valid `platform.yaml`
   - `python -m pytest` (from the repo root, with dev extras if needed: `pip install -e ".[dev]"`)
4. **Do not commit** secrets: AWS keys, `terraform.tfvars` with real accounts, kubeconfigs, or Vault tokens. Use examples and local-only files (see `.gitignore`).

## Code style

- Match existing patterns in the codebase (imports, typing, CLI style).
- Prefer small, readable changes over large drive-by refactors in the same PR.

## Questions

Open a discussion or issue on the hosting platform if you are unsure before investing a lot of time in a large change.
