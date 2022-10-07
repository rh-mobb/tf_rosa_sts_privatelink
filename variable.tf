variable "cluster_name" {
  type        = string
  default     = "poc-acm-mhs-tmp"
  description = "ROSA cluster name"
}

variable "region" {
  type        = string
  default     = "us-west-2"
  description = "ROSA cluster region"
}

variable "availability_zones" {
  type        = list
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]
  description = "ROSA cluster availability zones"
}

variable "bastion_key_loc" {
  type        = string
  default     = "~/.ssh/id_rsa.pub"
  description = "Public key for bastion host"
}

variable "bastion_ami" {
  type        = string
  default     = "ami-0ba62214afa52bec7"
  description = "Bastion AMI"
}

variable "bastion_instance_type" {
  type        = string
  default     = "t2.micro"
  description = "Bastion instance type"
}

variable "rosa_vpc_cidr_block" {
  type        = string
  default     = "10.64.0.0/16"
  description = "cidr range for rosa private vpc"
}

variable "rosa_subnet_cidr_blocks" {
  type        = list
  default     = ["10.64.0.0/24", "10.64.1.0/24", "10.64.2.0/24"]
  description = "cidr range for rosa private vpc"
}

variable "egress_vpc_cidr_block" {
  type        = string
  default     = "10.65.0.0/16"
  description = "cidr range for egress vpc"
}

variable "egress_prv_subnet_cidr_block" {
  type        = string
  default     = "10.65.1.0/24"
  description = "cidr range for private subnet in egress vpc"
}

variable "egress_pub_subnet_cidr_block" {
  type        = string
  default     = "10.65.2.0/24"
  description = "cidr range for pub subnet in egress vpc"
}

variable "tgw_cidr_block" {
  type        = string
  default     = "10.64.0.0/10"
  description = "cidr range that should be used for tgw"
}

variable "enable_rosa_jumphost" {
  description = "If set to true, deploy a jumphost in the ROSA private subnet"
  type        = bool
  default     = false
}
