variable "cluster_name" {
  type        = string
  default     = "rosa_prvlnk_sts"
  description = "ROSA cluster name"
}
variable "region" {
  type        = string
  default     = "us-east-2"
  description = "ROSA cluster region"
}
variable "bastion_key_loc" {
  type        = string
  default     = "~/.ssh/id_rsa.pub"
  description = "Public key for bastion host"
}
variable "vpc_cidr_block" {
  type        = string
  default     = "10.1.0.0/16"
  description = "cidr range for rosa private vpc"
}

variable "rosa_subnet_cidr_block" {
  type        = string
  default     = "10.1.0.0/16"
  description = "cidr range for rosa private vpc"
}

variable "egress_vpc_cidr_block" {
  type        = string
  default     = "10.2.0.0/16"
  description = "cidr range for egress vpc"
}

variable "egress_prv_subnet_cidr_block" {
  type        = string
  default     = "10.2.1.0/24"
  description = "cidr range for private subnet in egress vpc"
}

variable "egress_pub_subnet_cidr_block" {
  type        = string
  default     = "10.2.2.0/24"
  description = "cidr range for pub subnet in egress vpc"
}