##########################################
# VPC
##########################################

resource "aws_vpc" "vpc" {
  cidr_block                       = var.ipam_pool_id != null ? aws_vpc_ipam_preview_next_cidr.this[0].cidr : var.vpc_cidr
  enable_dns_hostnames             = var.enable_dns_hostnames
  enable_dns_support               = var.enable_dns_support
  assign_generated_ipv6_cidr_block = false
  instance_tenancy                 = var.instance_tenancy
  tags                             = merge(var.common_tags, tomap({"Name" = "${local.name_conv_vpc}${var.vpc_name}"}))
}

##########################################
# VPC IPAM CONDITIONAL
###########################################

resource "aws_vpc_ipam_preview_next_cidr" "this" {
  count         = var.ipam_pool_id != null ? 1 : 0
  ipam_pool_id  = var.ipam_pool_id
  netmask_length = var.netmask_length
}

###########################################
# DHCP Options Set
###########################################

locals {
  dhcp_options_domain_name = var.dhcp_options_domain_name != null ? var.dhcp_options_domain_name : "${var.region_acronym}.compute.internal"
}

resource "aws_vpc_dhcp_options" "dhcp_options" {
  count                = var.enable_dhcp_options ? 1 : 0
  domain_name          = local.dhcp_options_domain_name
  domain_name_servers  = var.dhcp_options_domain_name_servers
  ntp_servers          = var.dhcp_options_ntp_servers
  netbios_name_servers = var.dhcp_options_netbios_name_servers
  netbios_node_type    = var.dhcp_options_netbios_node_type
  tags                 = merge(var.common_tags, tomap({"Name" = "${local.name_conv_dhcp_ops}"}))
}

###########################################
# DHCP Options Set Association
###########################################

resource "aws_vpc_dhcp_options_association" "dhcp_options_association" {
  count           = var.enable_dhcp_options ? 1 : 0
  vpc_id          = aws_vpc.vpc.id
  dhcp_options_id = aws_vpc_dhcp_options.dhcp_options[0].id
}

##############################################
# Securing the default Security group
##############################################

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.vpc.id

  ingress = []
  egress  = []

  tags = merge(
    var.common_tags,
    {
      Name = "${var.vpc_name}-default-sg"
    }
  )
}
