output "extra_volume_ids" {
  value = {
    for k, v in aws_ebs_volume.extra : k => v.id
  }
}
