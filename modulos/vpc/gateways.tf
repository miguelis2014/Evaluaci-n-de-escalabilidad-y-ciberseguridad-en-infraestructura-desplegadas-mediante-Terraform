####################################################################################
# Creation of Internet Gateway
####################################################################################

resource "aws_internet_gateway" "igw_dc" {
  count = length(var.public_subnets) != 0 || length(var.public_subnets_edge) != 0 || length(var.public_subnets_nat) != 0 ? 1 : 0
  vpc_id = aws_vpc.vpc.id
  tags   = merge(var.common_tags, tomap({"Name" = "${local.name_conv_igw}"}))
}

####################################################################################
# Creation of NAT Gateway 
####################################################################################

resource "aws_eip" "nat_eip" {
  depends_on = [aws_internet_gateway.igw_dc]
  count     = length(var.public_subnets_nat) != 0 ? length(var.public_subnets_nat) : 0
  domain    = "vpc"
  tags      = merge(var.common_tags, tomap({"Name" = "${local.name_conv_eip}${var.public_subnets_nat[count.index].sname}"}))
}

resource "aws_eip" "additional_nat_eip" {
  depends_on = [aws_internet_gateway.igw_dc]
  count     = var.additional_eips_per_natgw != 0 ? var.additional_eips_per_natgw * length(var.public_subnets_nat) : 0
  domain    = "vpc"
  tags      = merge(var.common_tags, tomap({"Name" = "${local.name_conv_eip}${var.public_subnets_nat[floor(count.index / var.additional_eips_per_natgw)].sname}-0${(count.index % var.additional_eips_per_natgw) + 1}"}))
}

resource "aws_nat_gateway" "nat_gateway" {
  depends_on                     = [aws_eip.nat_eip]
  count                          = length(var.public_subnets_nat)
  allocation_id                  = element(aws_eip.nat_eip.*.id, count.index)
  secondary_allocation_ids       = var.additional_eips_per_natgw != 0 ? slice(aws_eip.additional_nat_eip.*.id,  count.index * var.additional_eips_per_natgw, (count.index * var.additional_eips_per_natgw) + var.additional_eips_per_natgw) : []
  subnet_id                      = element(aws_subnet.public_subnets_nat.*.id, count.index)
  tags                           = merge(var.common_tags, tomap({"Name" = "${local.name_conv_natgw}${element(var.azs, count.index)}"}))
}