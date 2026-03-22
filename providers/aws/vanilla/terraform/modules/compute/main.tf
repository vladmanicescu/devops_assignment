resource "tls_private_key" "this" {
  algorithm = "ED25519"
}

resource "local_file" "private_key_pem" {
  content         = tls_private_key.this.private_key_openssh
  filename        = "${path.root}/${var.key_name}.pem"
  file_permission = "0600"
}

resource "aws_key_pair" "this" {
  key_name   = var.key_name
  public_key = tls_private_key.this.public_key_openssh
}

locals {
  vm_map = {
    for vm in var.vm_definitions : vm.name => vm
  }
}

resource "aws_instance" "nodes" {
  for_each = local.vm_map

  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name               = aws_key_pair.this.key_name
  private_ip             = each.value.private_ip

  user_data = <<-EOF
              #cloud-config
              preserve_hostname: false
              hostname: ${each.value.hostname}
              fqdn: ${each.value.hostname}
              manage_etc_hosts: true
              EOF

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name     = each.value.name
    Hostname = each.value.hostname
    Gateway  = try(each.value.gateway, "")
    Role     = each.value.name == "k8s-cp1" ? "control-plane" : "worker"
  }
}

resource "aws_instance" "nfs_srv" {
  ami                    = var.ami_id
  instance_type          = var.nfs_instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name               = aws_key_pair.this.key_name
  private_ip             = cidrhost(var.subnet_cidr, var.nfs_host_index)

  user_data = <<-EOF
              #cloud-config
              preserve_hostname: false
              hostname: nfs-srv
              fqdn: nfs-srv
              manage_etc_hosts: true
              EOF

  root_block_device {
    volume_size           = var.nfs_root_volume_gb
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name = "nfs-srv"
    Role = "nfs-server"
  }
}

resource "aws_instance" "gitlab_srv" {
  ami                    = var.ami_id
  instance_type          = var.gitlab_instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name               = aws_key_pair.this.key_name
  private_ip             = cidrhost(var.subnet_cidr, var.gitlab_host_index)

  user_data = <<-EOF
              #cloud-config
              preserve_hostname: false
              hostname: gitlab-srv
              fqdn: gitlab-srv
              manage_etc_hosts: true
              EOF

  root_block_device {
    volume_size           = var.gitlab_root_volume_gb
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name = "gitlab-srv"
    Role = "gitlab"
  }
}
