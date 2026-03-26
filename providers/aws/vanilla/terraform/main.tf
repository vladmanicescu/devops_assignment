terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

locals {
  vm_map = {
    for vm in var.vm_definitions : vm.name => vm
  }

  ansible_inventory = <<-EOT
[k8s]
%{for vm_name, n in module.compute.k8s_nodes~}
${vm_name} ansible_host=${n.public_ip}
%{endfor~}

[nfs]
nfs-srv ansible_host=${module.compute.nfs_srv.public_ip}

[gitlab]
gitlab-srv ansible_host=${module.compute.gitlab_srv.public_ip}

[k8s:vars]
ansible_user=ec2-user
ansible_ssh_private_key_file=../terraform/${var.key_name}.pem
ansible_python_interpreter=/usr/bin/python3

[nfs:vars]
ansible_user=ec2-user
ansible_ssh_private_key_file=../terraform/${var.key_name}.pem
ansible_python_interpreter=/usr/bin/python3

[gitlab:vars]
ansible_user=ec2-user
ansible_ssh_private_key_file=../terraform/${var.key_name}.pem
ansible_python_interpreter=/usr/bin/python3
EOT
}

module "network" {
  source = "./modules/network"

  project_name      = var.project_name
  vpc_cidr          = var.vpc_cidr
  subnet_cidr       = var.subnet_cidr
  availability_zone = var.availability_zone
  allowed_ssh_cidrs = var.allowed_ssh_cidrs
}

module "compute" {
  source = "./modules/compute"

  key_name          = var.key_name
  ami_id            = data.aws_ssm_parameter.al2023_ami.value
  subnet_id         = module.network.subnet_id
  subnet_cidr       = var.subnet_cidr
  security_group_id = module.network.security_group_id
  instance_type     = var.instance_type
  root_volume_size  = var.root_volume_size
  vm_definitions    = var.vm_definitions
}

module "storage" {
  source = "./modules/storage"

  node_extra_disks = {
    for k, n in module.compute.k8s_nodes : k => {
      instance_id       = n.id
      availability_zone = n.availability_zone
      extra_disk_size   = local.vm_map[k].extra_disk_size
      disk_name         = k
    }
  }
}

resource "local_file" "ansible_inventory" {
  content         = local.ansible_inventory
  filename        = "${path.module}/../ansible/inventory.ini"
  file_permission = "0644"
}

# --- State migration: flat resources -> modules (avoid replace on next apply) ---
moved {
  from = aws_vpc.this
  to   = module.network.aws_vpc.this
}

moved {
  from = aws_internet_gateway.this
  to   = module.network.aws_internet_gateway.this
}

moved {
  from = aws_subnet.this
  to   = module.network.aws_subnet.this
}

moved {
  from = aws_route_table.public
  to   = module.network.aws_route_table.public
}

moved {
  from = aws_route_table_association.this
  to   = module.network.aws_route_table_association.this
}

moved {
  from = aws_security_group.nodes
  to   = module.network.aws_security_group.nodes
}

moved {
  from = tls_private_key.this
  to   = module.compute.tls_private_key.this
}

moved {
  from = local_file.private_key_pem
  to   = module.compute.local_file.private_key_pem
}

moved {
  from = aws_key_pair.this
  to   = module.compute.aws_key_pair.this
}

moved {
  from = aws_instance.nodes
  to   = module.compute.aws_instance.nodes
}

moved {
  from = aws_instance.nfs_srv
  to   = module.compute.aws_instance.nfs_srv
}

moved {
  from = aws_instance.gitlab_srv
  to   = module.compute.aws_instance.gitlab_srv
}

moved {
  from = aws_ebs_volume.extra
  to   = module.storage.aws_ebs_volume.extra
}

moved {
  from = aws_volume_attachment.extra
  to   = module.storage.aws_volume_attachment.extra
}
