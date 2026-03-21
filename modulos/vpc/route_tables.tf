####################################################################################
# Public subnet routes - 0.0.0.0/ to IGW
####################################################################################
resource "aws_route_table" "public_subnets" {
  count  = length(var.public_subnets) != 0 ? length(var.public_subnets) : 0
  vpc_id = aws_vpc.vpc.id
  tags   = merge(var.common_tags, tomap({"Name" = "${local.name_conv_rt}${var.public_subnets[count.index].sname}"}))
}

resource "aws_route" "public_subnets" {
  depends_on             = [aws_internet_gateway.igw_dc]
  count                  = length(var.public_subnets)
  route_table_id         = aws_route_table.public_subnets[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw_dc[0].id
}

resource "aws_route_table_association" "public_subnets" {
  depends_on     = [aws_route_table.public_subnets]
  count          = length(var.public_subnets)
  route_table_id = aws_route_table.public_subnets[count.index].id
  subnet_id      = aws_subnet.public_subnets[count.index].id
}

####################################################################################
# Public subnets routes with nat gateway - 0.0.0.0/ to igw (Isolated route tables for the NAT GW)
####################################################################################
resource "aws_route_table" "public_subnets_nat" {
  count  = length(var.public_subnets_nat) !=0 ? length(var.public_subnets_nat) : 0
  vpc_id = aws_vpc.vpc.id
  tags   = merge(var.common_tags, tomap({"Name" = "${local.name_conv_rt}${var.public_subnets_nat[count.index].sname}"}))
}

resource "aws_route" "public_subnets_nat" {
  depends_on             = [aws_internet_gateway.igw_dc]
  count                  = length(var.public_subnets_nat) !=0 ? length(var.public_subnets_nat) : 0
  route_table_id         = aws_route_table.public_subnets_nat[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw_dc[0].id
}

resource "aws_route_table_association" "public_subnets_nat" {
  depends_on     = [aws_route_table.public_subnets_nat]
  count          = length(var.public_subnets_nat) !=0 ? length(var.public_subnets_nat) : 0
  route_table_id = aws_route_table.public_subnets_nat[count.index].id
  subnet_id      = aws_subnet.public_subnets_nat[count.index].id
}

####################################################################################
# Public subnet routes with Edge Association - there cannot be a route to 0.0.0.0/0 - The same route table for all three networks because the association is done at the route table level
####################################################################################
resource "aws_route_table" "public_subnets_edge" {
  count  = length(var.public_subnets_edge) != 0 ? 1 : 0
  vpc_id = aws_vpc.vpc.id
  tags   = merge(var.common_tags, tomap({"Name" = "${local.name_conv_rt_igw}"}))
}

resource "aws_route_table_association" "public_subnets_edge" {
  depends_on     = [aws_route_table.public_subnets_edge]
  count          = length(var.public_subnets_edge) !=0 ? length(var.public_subnets_edge) : 0
  route_table_id = aws_route_table.public_subnets_edge[0].id
  subnet_id      = "${element(aws_subnet.public_subnets_edge.*.id, count.index)}"
}

resource "aws_route_table_association" "public_subnets_edge-igw" {
  depends_on     = [aws_route_table.public_subnets_edge]
  count          = length(var.public_subnets_edge) !=0 ? 1 : 0
  route_table_id = aws_route_table.public_subnets_edge[0].id
  gateway_id     = aws_internet_gateway.igw_dc[0].id
}


####################################################################################
# Private network routes with 0.0.0.0/0 pointing to the nat gateway of your AZ.
####################################################################################
resource "aws_route_table" "private_subnets_nat" {
  count     = length(var.private_subnets_nat) != 0 && length(var.public_subnets_nat) !=0 ? length(var.private_subnets_nat) : 0
  vpc_id    = aws_vpc.vpc.id
  tags      = merge(var.common_tags, tomap({"Name" = "${local.name_conv_rt}${var.private_subnets_nat[count.index].sname}"}))
}

resource "aws_route_table_association" "private_subnets_nat" {
  depends_on     = [aws_route_table.private_subnets_nat]
  count          = length(var.private_subnets_nat) != 0 && length(var.public_subnets_nat) !=0 ? length(var.private_subnets_nat) : 0
  route_table_id = "${element(aws_route_table.private_subnets_nat.*.id, count.index)}"
  subnet_id      = "${element(aws_subnet.private_subnets_nat.*.id, count.index)}"
}

resource "aws_route" "private_subnets_nat" {
  depends_on             = [aws_nat_gateway.nat_gateway]
  count                  = length(var.private_subnets_nat) != 0 && length(var.public_subnets_nat) !=0 ? length(var.private_subnets_nat) : 0
  route_table_id         = aws_route_table.private_subnets_nat[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${element(aws_nat_gateway.nat_gateway.*.id, count.index)}"
}

####################################################################################
# Private network routes. 1 subnet -> 1 route table (isolated)
####################################################################################
resource "aws_route_table" "private_subnets_isolated" {
  count     = length(var.private_subnets_isolated) != 0 ? length(var.private_subnets_isolated) : 0
  vpc_id    = aws_vpc.vpc.id
  tags      = merge(var.common_tags, tomap({"Name" = "${local.name_conv_rt}${var.private_subnets_isolated[count.index].sname}"}))
}

resource "aws_route_table_association" "private_subnets_isolated" {
  depends_on     = [aws_route_table.private_subnets_isolated]
  count          = length(var.private_subnets_isolated)
  route_table_id = "${element(aws_route_table.private_subnets_isolated.*.id, count.index)}"
  subnet_id      = "${element(aws_subnet.private_subnets_isolated.*.id, count.index)}"
}

####################################################################################
# Horizontal routes of private networks block 1. n subnets -> 1 route table (horizontal or by tier)
####################################################################################
resource "aws_route_table" "private_subnets_horizontal_1" {
  count     = length(var.private_subnets_horizontal_1) / length(var.azs)
  vpc_id    = aws_vpc.vpc.id
  tags      = merge(var.common_tags, tomap({"Name" = "${local.name_conv_rt}${var.private_subnets_horizontal_1[count.index * length(var.azs)].sname}"}))
}

resource "aws_route_table_association" "private_subnets_horizontal_1" {
  depends_on     = [aws_route_table.private_subnets_horizontal_1]
  count          = length(var.private_subnets_horizontal_1)
  route_table_id = aws_route_table.private_subnets_horizontal_1[floor((count.index) / length(var.azs))].id
  subnet_id      = "${element(aws_subnet.private_subnets_horizontal_1.*.id, count.index)}"
}

####################################################################################
# Vertical routes of private networks block 1. n subnets -> 1 route table (vertical or per AZ)
####################################################################################
resource "aws_route_table" "private_subnets_vertical_1" {
  count     = length(var.private_subnets_vertical_1) != 0 ? length(var.azs) : 0
  vpc_id    = aws_vpc.vpc.id
  tags      = merge(var.common_tags, tomap({"Name" = "${local.name_conv_rt}${var.private_subnets_vertical_1[count.index].sname}"}))
}

resource "aws_route_table_association" "private_subnets_vertical_1" {
  depends_on     = [aws_route_table.private_subnets_vertical_1]
  count          = length(var.private_subnets_vertical_1)
  route_table_id = "${element(aws_route_table.private_subnets_vertical_1.*.id, count.index)}"
  subnet_id      = "${element(aws_subnet.private_subnets_vertical_1.*.id, count.index)}"
}


####################################################################################
# Horizontal routes of private networks block 2. n subnets -> 1 route table (horizontal or by tier)
####################################################################################
resource "aws_route_table" "private_subnets_horizontal_2" {
  count     = length(var.private_subnets_horizontal_2) / length(var.azs)
  vpc_id    = aws_vpc.vpc.id
  tags      = merge(var.common_tags, tomap({"Name" = "${local.name_conv_rt}${var.private_subnets_horizontal_2[count.index * length(var.azs)].sname}"}))
}

resource "aws_route_table_association" "private_subnets_horizontal_2" {
  depends_on     = [aws_route_table.private_subnets_horizontal_2]
  count          = length(var.private_subnets_horizontal_2)
  route_table_id = aws_route_table.private_subnets_horizontal_2[floor((count.index) / length(var.azs))].id
  subnet_id      = "${element(aws_subnet.private_subnets_horizontal_2.*.id, count.index)}"
}

####################################################################################
# Vertical routes of private networks block 2. n subnets -> 1 route table (vertical or per AZ)
####################################################################################
resource "aws_route_table" "private_subnets_vertical_2" {
  count     = length(var.private_subnets_vertical_2) != 0 ? length(var.azs) : 0
  vpc_id    = aws_vpc.vpc.id
  tags      = merge(var.common_tags, tomap({"Name" = "${local.name_conv_rt}${var.private_subnets_vertical_2[count.index].sname}"}))
}

resource "aws_route_table_association" "private_subnets_vertical_2" {
  depends_on     = [aws_route_table.private_subnets_vertical_2]
  count          = length(var.private_subnets_vertical_2)
  route_table_id = "${element(aws_route_table.private_subnets_vertical_2.*.id, count.index)}"
  subnet_id      = "${element(aws_subnet.private_subnets_vertical_2.*.id, count.index)}"
}

####################################################################################
# Horizontal routes of private networks block 2. n subnets -> 1 route table (horizontal or by tier)
####################################################################################
resource "aws_route_table" "private_subnets_horizontal_3" {
  count     = length(var.private_subnets_horizontal_3) / length(var.azs)
  vpc_id    = aws_vpc.vpc.id
  tags      = merge(var.common_tags, tomap({"Name" = "${local.name_conv_rt}${var.private_subnets_horizontal_3[count.index * length(var.azs)].sname}"}))
}

resource "aws_route_table_association" "private_subnets_horizontal_3" {
  depends_on     = [aws_route_table.private_subnets_horizontal_3]
  count          = length(var.private_subnets_horizontal_3)
  route_table_id = aws_route_table.private_subnets_horizontal_3[floor((count.index) / length(var.azs))].id
  subnet_id      = "${element(aws_subnet.private_subnets_horizontal_3.*.id, count.index)}"
}

####################################################################################
# Vertical routes of private networks block 2. n subnets -> 1 route table (vertical or per AZ)
####################################################################################
resource "aws_route_table" "private_subnets_vertical_3" {
  count     = length(var.private_subnets_vertical_3) != 0 ? length(var.azs) : 0
  vpc_id    = aws_vpc.vpc.id
  tags      = merge(var.common_tags, tomap({"Name" = "${local.name_conv_rt}${var.private_subnets_vertical_3[count.index].sname}"}))
}

resource "aws_route_table_association" "private_subnets_vertical_3" {
  depends_on     = [aws_route_table.private_subnets_vertical_3]
  count          = length(var.private_subnets_vertical_3)
  route_table_id = "${element(aws_route_table.private_subnets_vertical_3.*.id, count.index)}"
  subnet_id      = "${element(aws_subnet.private_subnets_vertical_3.*.id, count.index)}"
}