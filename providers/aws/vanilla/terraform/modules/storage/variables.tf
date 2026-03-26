variable "node_extra_disks" {
  description = "Per Kubernetes node: instance id, AZ, disk size, and tag name"
  type = map(object({
    instance_id       = string
    availability_zone = string
    extra_disk_size   = number
    disk_name         = string
  }))
}
