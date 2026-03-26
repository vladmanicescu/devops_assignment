output "k8s_nodes" {
  value = {
    for k, inst in aws_instance.nodes : k => {
      id                = inst.id
      public_ip         = inst.public_ip
      private_ip        = inst.private_ip
      availability_zone = inst.availability_zone
    }
  }
}

output "nfs_srv" {
  value = {
    id                = aws_instance.nfs_srv.id
    public_ip         = aws_instance.nfs_srv.public_ip
    private_ip        = aws_instance.nfs_srv.private_ip
    availability_zone = aws_instance.nfs_srv.availability_zone
  }
}

output "gitlab_srv" {
  value = {
    id                = aws_instance.gitlab_srv.id
    public_ip         = aws_instance.gitlab_srv.public_ip
    private_ip        = aws_instance.gitlab_srv.private_ip
    availability_zone = aws_instance.gitlab_srv.availability_zone
  }
}

output "private_key_path" {
  value = local_file.private_key_pem.filename
}
