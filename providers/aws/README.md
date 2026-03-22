# AWS providers

| Path | Stack |
|------|--------|
| [vanilla/](vanilla/README.md) | Self-managed kubeadm on EC2 + NFS + GitLab VMs (Terraform + Ansible) |
| [eks/](eks/README.md) | Managed EKS cluster + VPC (Terraform only) |

Choose **vanilla** for the full lab/GitLab path, or **EKS** for a managed control plane and standard `aws eks update-kubeconfig` access.
