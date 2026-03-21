# variables.tf

variable "region" {
  description = "AWS region where the resources will be deployed"
  type    = string
  default = "eu-west-1"
}

variable "region_acronym" {
  description = "An acronym of the region name used."
  type    = string
  default = "ew1"
}

variable "environment" {
  description = "Name of the environment where the infrastructure is deployed (e.g., dev, test, prod)"
  type    = string
  default = ""
}

variable "project" {
  type    = string
  default = "project"
}

######################################################
# VPC variables
######################################################

variable "vpc_name" {
  description = "Name of the VPC."
  type = string
  default = ""
}

variable "instance_tenancy" {
  description = "A tenancy option for instances launched into the VPC"
  type        = string
  default     = "default"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC (only used if IPAM is not specified)"
  default = null

  validation {
    condition     = var.vpc_cidr == null || (can(cidrsubnet(var.vpc_cidr, 0, 0)) && tonumber(split("/", var.vpc_cidr)[1]) >= 17)
    error_message = "CIDR must be valid and /17 or larger (e.g., /16, /15) if provided."
  }
}

variable "enable_dhcp_options" {
  description = "Should be true to create dhcp options"
  type        = bool
  default     = true
}

variable "dhcp_options_netbios_node_type" {
  description = "Specify netbios node_type for DHCP options set (requires enable_dhcp_options set to true)"
  type        = string
  default     = ""
}

variable "enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Should be true to enable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "dhcp_options_domain_name" {
  description = "The suffix domain name to use by default when resolving non Fully Qualified Domain Names"
  type        = string
  default     = null
}

variable "dhcp_options_domain_name_servers" {
  description = "Specify a list of DNS server addresses for DHCP options set, default to AWS provided (requires enable_dhcp_options set to true)"
  type        = list(string)
  default     = ["AmazonProvidedDNS"]
}

variable "dhcp_options_ntp_servers" {
  description = "Specify a list of NTP servers for DHCP options set (requires enable_dhcp_options set to true)"
  type        = list(string)
  default     = []
}

variable "dhcp_options_netbios_name_servers" {
  description = "Specify a list of netbios servers for DHCP options set (requires enable_dhcp_options set to true)"
  type        = list(string)
  default     = []
}

variable "common_tags" {
  description = "Extra tags to apply to resources"
  type    = map(any)
  default = {}
}

variable "ipam_pool_id" {
  type        = string
  description = "Optional: IPAM Pool ID to get a CIDR from automatically"
  default     = null
}

variable "netmask_length" {
  type        = number
  description = "Optional: Netmask length to request from IPAM (e.g., 16, 17)"
  default     = 16
}

######################################################
# subnets variables
######################################################

variable "private_subnets_isolated" {
  description = "List of isolated private subnets, each associated with a dedicated route table without default routes"
  type = list(object({
    sname = string
    CIDR  = string
    AZ    = string
    tags  = map(string)
  }))
  default = []
}

variable "private_subnets_nat" {
  description = "List of private subnets using NAT Gateway for internet access. Each subnet gets its own route table with a route to the NAT Gateway"
  type = list(object({
    sname = string
    CIDR  = string
    AZ    = string
    tags  = map(string)
  }))
  default = []
}

variable "private_subnets_horizontal_1" {
  description = "First block of horizontally grouped private subnets, sharing a route table across multiple AZs"
  type = list(object({
    sname = string
    CIDR  = string
    AZ    = string
    tags  = map(string)
  }))
  default = []
}

variable "private_subnets_horizontal_2" {
  description = "Second block of horizontally grouped private subnets, sharing a route table across multiple AZs"
  type = list(object({
    sname = string
    CIDR  = string
    AZ    = string
    tags  = map(string)
  }))
  default = []
}

variable "private_subnets_horizontal_3" {
  description = "Third block of horizontally grouped private subnets, sharing a route table across multiple AZs"
  type = list(object({
    sname = string
    CIDR  = string
    AZ    = string
    tags  = map(string)
  }))
  default = []
}

variable "private_subnets_vertical_1" {
  description = "First block of vertically grouped private subnets, where all subnets in the same AZ share a route table"
  type = list(object({
    sname = string
    CIDR  = string
    AZ    = string
    tags  = map(string)
  }))
  default = []
}

variable "private_subnets_vertical_2" {
  description = "Second block of vertically grouped private subnets, where all subnets in the same AZ share a route table"
  type = list(object({
    sname = string
    CIDR  = string
    AZ    = string
    tags  = map(string)
  }))
  default = []
}

variable "private_subnets_vertical_3" {
  description = "Third block of vertically grouped private subnets, where all subnets in the same AZ share a route table"
  type = list(object({
    sname = string
    CIDR  = string
    AZ    = string
    tags  = map(string)
  }))
  default = []
}

variable "public_subnets" {
  description = "List of public subnets, each with its own route table and default route to an Internet Gateway"
  type = list(object({
    sname = string
    CIDR  = string
    AZ    = string
    tags  = map(string)
  }))
  default = []
}

variable "public_subnets_nat" {
  description = "List of public subnets designated for hosting NAT Gateways. Maximum of 3 subnets supported (one per AZ)"
  type = list(object({
    sname = string
    CIDR  = string
    AZ    = string
    tags  = map(string)
  }))
  default = []
  validation {
    condition     = length(var.public_subnets_nat) <= 3
    error_message = "There can only be up to 3 networks for the NAT Gateway, one per AZ"
  }
}

variable "public_subnets_edge" {
  description = "List of public subnets associated with a shared route table for Internet Gateway edge associations. Maximum of 3 subnets supported (one per AZ)"
  type = list(object({
    sname = string
    CIDR  = string
    AZ    = string
    tags  = map(string)
  }))
  default = []
  validation {
    condition     = length(var.public_subnets_edge) <= 3
    error_message = "There can only be up to 3 networks for the IGW Gateway, one per AZ"
  }
}

variable "azs" {
  type        = list(any)
  description = "AZs in which the subnets will be launched. If you want to add new AZs, they must be consecutive to the last one."
  default     = ["a", "b", "c"]
}

variable "horizontal_routes" {
  description = "Flag to enable or disable the creation of route tables shared across availability zones (horizontal tiers)"
  type = bool
  default = true
}

variable "additional_eips_per_natgw" {
  type = number
  default = 0
  description = "Additional EIPs to attach to a nat gateway. By default, this module associate 1 EIP for 1 Nat GW. This variable adds more. NOTE: There is a soft limit of 2. Request new quota value before if this variable get value greater than 2."
    validation {
    condition     = var.additional_eips_per_natgw <= 7
    error_message = "Only a maximum of 7 additional EIPs are allowed, as a NAT Gateway can have up to 8 EIPs."
  }
}