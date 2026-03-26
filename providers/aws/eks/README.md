# AWS — EKS

Managed Kubernetes (EKS) with a dedicated VPC (public + private subnets, NAT), using the official Terraform modules:

- [terraform-aws-modules/vpc/aws](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws)
- [terraform-aws-modules/eks/aws](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws)

This path does **not** include the vanilla stack’s NFS VM or GitLab VM; add workloads with Helm/kubectl after `aws eks update-kubeconfig`, or combine with other tooling as needed.

From the repo root, **pocket** applies **EKS + Vault + CSI** in one shot (no make required):

```bash
pocket apply --run
```

Alternatively, `make infra-eks` runs `pocket apply` then Terraform for Makefile-based workflows.

Or manually:

```bash
pocket apply --config platform.yaml
cd providers/aws/eks/terraform && terraform init && terraform apply
terraform output -raw configure_kubeconfig
```

Use the printed `aws eks update-kubeconfig ...` command (with your profile/region) to talk to the cluster.

## Vault (KMS + IRSA)

`platform.yaml` controls Vault under `platform.vault` (`enabled`, optional `replicas`, `data_storage_size`). **pocket** writes `terraform.tfvars` and can drive Terraform:

```bash
pocket validate
pocket vault plan      # terraform plan (EKS + Vault)
pocket vault install   # terraform apply (same state as the cluster)
pocket vault init      # one-time: JSON init + store root token & recovery keys in Secret `vault/pocket-vault-bootstrap`
pocket vault token     # where the token lives; `pocket vault token --export` for eval
pocket vault status
```

Terraform provisions:

- A dedicated **KMS key** (alias `<cluster_name>-vault-seal`) for the `awskms` seal
- An **IAM role** (IRSA) for the `vault:vault` service account
- **HashiCorp Vault** via Helm (Raft storage; listener TLS off for in-cluster use — harden for production)

To **disable** Vault, set `vault.enabled: false` in `platform.yaml`, run `pocket apply` (writes tfvars) then `terraform apply` or `make infra-eks`.

See `terraform output vault_init_hint` and `terraform output vault_kms_alias` for details.

## External Secrets Operator + Vault

Terraform installs the **External Secrets Operator** (Helm in `external-secrets` namespace; CRDs included). The **ClusterSecretStore** is **not** in Terraform (the provider validates CRDs at *plan* time before Helm installs them). It is applied by **`pocket vault bootstrap`** from `providers/aws/eks/terraform/manifests/eso-cluster-secret-store.yaml`.

If you previously hit a failed `kubernetes_manifest` apply, remove it from state:  
`terraform state rm 'kubernetes_manifest.cluster_secret_store_vault[0]'` (then `terraform apply`).

After `pocket vault init`, the root token is in **`vault/pocket-vault-bootstrap`** (also **`pocket vault token --export`**). **`pocket vault bootstrap`** uses that Secret automatically if **`VAULT_TOKEN`** is unset. Optional explicit token:

```bash
eval "$(pocket vault token --export)"
pocket vault bootstrap
```

Then create **ExternalSecret** resources that reference `secretStoreRef.name: vault` and paths under the **`secret/`** KV v2 engine.

**Local CLI / UI** to Vault:

```bash
pocket vault port-forward   # http://127.0.0.1:8200  —  Ctrl+C to stop
export VAULT_ADDR=http://127.0.0.1:8200
vault login
```
