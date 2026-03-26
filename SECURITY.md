# Security

## Reporting a vulnerability

If you believe you have found a **security vulnerability**, please **do not** open a public issue with exploit details.

Instead, contact the maintainers privately (e.g. via the security advisory feature on GitHub, or email if published in the repository profile). Include:

- A short description of the issue and affected component
- Steps to reproduce (if safe to share)
- Impact assessment if you can

We will work with you to understand and address the report before any public disclosure.

## General hygiene

This repository is **infrastructure and tooling**. Treat any clone as capable of provisioning real cloud resources. Never commit credentials, state files, or production `terraform.tfvars`.
