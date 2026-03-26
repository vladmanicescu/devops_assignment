output "k8s_public_ips" {
  value = {
    for name, n in module.compute.k8s_nodes : name => n.public_ip
  }
}

output "k8s_private_ips" {
  value = {
    for name, n in module.compute.k8s_nodes : name => n.private_ip
  }
}

output "nfs_public_ip" {
  value = module.compute.nfs_srv.public_ip
}

output "nfs_private_ip" {
  value = module.compute.nfs_srv.private_ip
}

output "gitlab_public_ip" {
  value = module.compute.gitlab_srv.public_ip
}

output "gitlab_private_ip" {
  value = module.compute.gitlab_srv.private_ip
}

output "ssh_private_key_path" {
  value = module.compute.private_key_path
}

output "ansible_inventory_path" {
  value = local_file.ansible_inventory.filename
}
