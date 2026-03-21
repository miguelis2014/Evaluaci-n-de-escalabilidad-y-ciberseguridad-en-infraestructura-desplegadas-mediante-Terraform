####################################################################################
# Isolated private subnets, each subnet will have its own routing table
####################################################################################

resource "aws_subnet" "private_subnets_isolated" {
  count = length(var.private_subnets_isolated) != 0 ? length(var.private_subnets_isolated) : 0
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_subnets_isolated[count.index].CIDR
  availability_zone       = "${var.region}${var.private_subnets_isolated[count.index].AZ}"
  map_public_ip_on_launch = false

  tags = merge(var.common_tags, var.private_subnets_isolated[count.index].tags, tomap({"Name" = "${local.name_conv_snet}${var.private_subnets_isolated[count.index].sname}"}))

}

####################################################################################
# Horizontal private subnets block 1. Each tier of subnets will be associated with a routing table. Number of horizontal subnets/number of azs = number of tiers.
####################################################################################

resource "aws_subnet" "private_subnets_horizontal_1" {
  count = length(var.private_subnets_horizontal_1) != 0 ? length(var.private_subnets_horizontal_1) : 0
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_subnets_horizontal_1[count.index].CIDR
  availability_zone       = "${var.region}${var.private_subnets_horizontal_1[count.index].AZ}"
  map_public_ip_on_launch = false

  tags = merge(var.common_tags, var.private_subnets_horizontal_1[count.index].tags, tomap({"Name" = "${local.name_conv_snet}${var.private_subnets_horizontal_1[count.index].sname}"}))

}

####################################################################################
# Vertical private subnets block 1 . Route tables are created per AZ. Subnets are linked to the route table created for their AZ.  The number of routes = number of AZs
####################################################################################

resource "aws_subnet" "private_subnets_vertical_1" {
  count = length(var.private_subnets_vertical_1) != 0 ? length(var.private_subnets_vertical_1) : 0
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_subnets_vertical_1[count.index].CIDR
  availability_zone       = "${var.region}${var.private_subnets_vertical_1[count.index].AZ}"
  map_public_ip_on_launch = false

  tags = merge(var.common_tags, var.private_subnets_vertical_1[count.index].tags, tomap({"Name" = "${local.name_conv_snet}${var.private_subnets_vertical_1[count.index].sname}"}))

}

####################################################################################
# Horizontal private subnets block 2. Each tier of subnets will be associated with a routing table. Number of horizontal subnets / number of azs = number of tiers.
####################################################################################

resource "aws_subnet" "private_subnets_horizontal_2" {
  count = length(var.private_subnets_horizontal_2) != 0 ? length(var.private_subnets_horizontal_2) : 0
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_subnets_horizontal_2[count.index].CIDR
  availability_zone       = "${var.region}${var.private_subnets_horizontal_2[count.index].AZ}"
  map_public_ip_on_launch = false

  tags = merge(var.common_tags, var.private_subnets_horizontal_2[count.index].tags, tomap({"Name" = "${local.name_conv_snet}${var.private_subnets_horizontal_2[count.index].sname}"}))

}

####################################################################################
# Vertical private subnets block 2. Route talbes are created per AZ. Subnets are linked to the route table for their AZ. The number of routes = number of AZs
####################################################################################

resource "aws_subnet" "private_subnets_vertical_2" {
  count = length(var.private_subnets_vertical_2) != 0 ? length(var.private_subnets_vertical_2) : 0
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_subnets_vertical_2[count.index].CIDR
  availability_zone       = "${var.region}${var.private_subnets_vertical_2[count.index].AZ}"
  map_public_ip_on_launch = false

  tags = merge(var.common_tags, var.private_subnets_vertical_2[count.index].tags, tomap({"Name" = "${local.name_conv_snet}${var.private_subnets_vertical_2[count.index].sname}"}))

}

####################################################################################
# Horizontal private subnets block 3. Each tier of subnets will be associated with a routing table. Number of horizontal subnets/number of azs = number of tiers.
####################################################################################

resource "aws_subnet" "private_subnets_horizontal_3" {
  count = length(var.private_subnets_horizontal_3) != 0 ? length(var.private_subnets_horizontal_3) : 0
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_subnets_horizontal_3[count.index].CIDR
  availability_zone       = "${var.region}${var.private_subnets_horizontal_3[count.index].AZ}"
  map_public_ip_on_launch = false

  tags = merge(var.common_tags, var.private_subnets_horizontal_3[count.index].tags, tomap({"Name" = "${local.name_conv_snet}${var.private_subnets_horizontal_3[count.index].sname}"}))

}

####################################################################################
# Vertical private subnets block 3. Route talbes are created per AZ. Subnets are linked to the route table for their AZ. The number of routes = number of AZs
####################################################################################

resource "aws_subnet" "private_subnets_vertical_3" {
  count = length(var.private_subnets_vertical_3) != 0 ? length(var.private_subnets_vertical_3) : 0
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_subnets_vertical_3[count.index].CIDR
  availability_zone       = "${var.region}${var.private_subnets_vertical_3[count.index].AZ}"
  map_public_ip_on_launch = false

  tags = merge(var.common_tags, var.private_subnets_vertical_3[count.index].tags, tomap({"Name" = "${local.name_conv_snet}${var.private_subnets_vertical_3[count.index].sname}"}))

}

####################################################################################
# Private subnets behind NAT will have 0.0.0.0/ pointing to a NAT gateway
####################################################################################

resource "aws_subnet" "private_subnets_nat" {
  count = length(var.private_subnets_nat) != 0 ? length(var.private_subnets_nat) : 0
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_subnets_nat[count.index].CIDR
  availability_zone       = "${var.region}${var.private_subnets_nat[count.index].AZ}"
  map_public_ip_on_launch = false

  tags = merge(var.common_tags, var.private_subnets_nat[count.index].tags, tomap({"Name" = "${local.name_conv_snet}${var.private_subnets_nat[count.index].sname}"}))

}

####################################################################################
# Public subnets will have 0.0.0.0/ route to the IGW
####################################################################################

resource "aws_subnet" "public_subnets" {
  count = length(var.public_subnets) != 0 ? length(var.public_subnets) : 0
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnets[count.index].CIDR
  availability_zone       = "${var.region}${var.public_subnets[count.index].AZ}"
  map_public_ip_on_launch = false

  tags = merge(var.common_tags, var.public_subnets[count.index].tags, tomap({"Name" = "${local.name_conv_snet}${var.public_subnets[count.index].sname}"}))

}

####################################################################################
# Public subnets for the nat gateway have a 0.0.0.0/ route to the IGW, but the module automativally creates nat gateways in this subnet
####################################################################################

resource "aws_subnet" "public_subnets_nat" {
  count = length(var.public_subnets_nat) != 0 ? length(var.public_subnets_nat) : 0
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnets_nat[count.index].CIDR
  availability_zone       = "${var.region}${var.public_subnets_nat[count.index].AZ}"
  map_public_ip_on_launch = false

  tags = merge(var.common_tags, var.public_subnets_nat[count.index].tags, tomap({"Name" = "${local.name_conv_snet}${var.public_subnets_nat[count.index].sname}"}))

}

####################################################################################
# Public subnets linked to the IGW cannot have a route to 0.0.0.0/0 but have an edge association with the IGW
####################################################################################

resource "aws_subnet" "public_subnets_edge" {
  count = length(var.public_subnets_edge) != 0 ? length(var.public_subnets_edge) : 0
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnets_edge[count.index].CIDR
  availability_zone       = "${var.region}${var.public_subnets_edge[count.index].AZ}"
  map_public_ip_on_launch = false

  tags = merge(var.common_tags, var.public_subnets_edge[count.index].tags, tomap({"Name" = "${local.name_conv_snet}${var.public_subnets_edge[count.index].sname}"}))
 
}