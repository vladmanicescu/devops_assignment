variable "key_name" {
  type = string
}

variable "ami_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "subnet_cidr" {
  type        = string
  description = "Used with host indices for nfs/gitlab static private IPs (cidrhost)."
}

variable "security_group_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "nfs_instance_type" {
  type        = string
  description = "EC2 type for the dedicated NFS host"
  default     = "t3.medium"
}

variable "gitlab_instance_type" {
  type        = string
  description = "EC2 type for the dedicated GitLab host"
  default     = "t3.large"
}

variable "root_volume_size" {
  type = number
}

variable "nfs_root_volume_gb" {
  type    = number
  default = 30
}

variable "gitlab_root_volume_gb" {
  type    = number
  default = 50
}

variable "nfs_host_index" {
  type        = number
  description = "Fourth octet index for cidrhost(subnet_cidr, nfs_host_index); default 20 matches prior main.tf."
  default     = 20
}

variable "gitlab_host_index" {
  type        = number
  description = "Fourth octet index for cidrhost(subnet_cidr, gitlab_host_index); default 30 matches prior main.tf."
  default     = 30
}

variable "vm_definitions" {
  type = list(object({
    name            = string
    hostname        = string
    private_ip      = string
    gateway         = optional(string)
    extra_disk_size = number
  }))
}
