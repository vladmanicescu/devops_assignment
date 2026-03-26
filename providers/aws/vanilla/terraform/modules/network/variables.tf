variable "project_name" {
  type        = string
  description = "Prefix for resource names and tags"
}

variable "vpc_cidr" {
  type = string
}

variable "subnet_cidr" {
  type = string
}

variable "availability_zone" {
  type = string
}

variable "allowed_ssh_cidrs" {
  type = list(string)
}
