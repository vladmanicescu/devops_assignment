resource "aws_ebs_volume" "extra" {
  for_each = var.node_extra_disks

  availability_zone = each.value.availability_zone
  size              = each.value.extra_disk_size
  type              = "gp3"

  tags = {
    Name = "${each.value.disk_name}-extra-disk"
  }
}

resource "aws_volume_attachment" "extra" {
  for_each = var.node_extra_disks

  device_name  = "/dev/sdf"
  volume_id    = aws_ebs_volume.extra[each.key].id
  instance_id  = each.value.instance_id
  force_detach = true
}
