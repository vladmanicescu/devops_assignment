# AWS — EKS

Managed Kubernetes (EKS) with a dedicated VPC (public + private subnets, NAT), using the official Terraform modules:

- [terraform-aws-modules/vpc/aws](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws)
- [terraform-aws-modules/eks/aws](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws)

This path does **not** include the vanilla stack’s NFS VM or GitLab VM; add workloads with Helm/kubectl after `aws eks update-kubeconfig`, or combine with other tooling as needed.

From the repo root:

```bash
cd providers/aws/eks/terraform
terraform init
terraform apply
terraform output configure_kubectl
```

Use the printed `aws eks update-kubeconfig ...` command (with your profile/region) to talk to the cluster.
