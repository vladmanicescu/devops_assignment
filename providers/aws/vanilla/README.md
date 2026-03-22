# AWS — vanilla Kubernetes

Infrastructure and configuration for a self-managed kubeadm cluster on EC2, plus NFS and GitLab VMs, live here:

- `terraform/` — root stack wires **modules**: `network` (VPC, subnet, routing, security group), `compute` (SSH key pair, EC2 for k8s/NFS/GitLab), `storage` (extra EBS per k8s node); generated Ansible inventory at `../ansible/inventory.ini`
- `ansible/` — node prep, cluster, NFS, GitLab, bootstrap

From the repository root, use `make infra`, `make config`, and the other targets; `makefile` points `TERRAFORM_DIR` and `ANSIBLE_DIR` at these paths.
