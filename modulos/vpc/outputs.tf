# VPC output variables
output "vpc_id" {
  value = aws_vpc.vpc.id
}
output "vpc_cidr" {
  value = var.vpc_cidr
}

output "vpc_name" {
  value = local.name_conv_vpc
}

# Subnet output variables
#isolated private
output "private_subnets_isolated_id" {
  value = aws_subnet.private_subnets_isolated.*.id == null ? [] : aws_subnet.private_subnets_isolated.*.id
}
output "private_subnets_isolated_cidr" {
  value = aws_subnet.private_subnets_isolated.*.cidr_block == null ? [] : aws_subnet.private_subnets_isolated.*.cidr_block
}
#private nat
output "private_subnets_nat_id" {
  value = aws_subnet.private_subnets_nat.*.id == null ? [] : aws_subnet.private_subnets_nat.*.id
}
output "private_subnets_nat_cidr" {
  value = aws_subnet.private_subnets_nat.*.cidr_block == null ? [] : aws_subnet.private_subnets_nat.*.cidr_block
}
#private vertical
output "private_subnets_vertical_1_id" {
  value = aws_subnet.private_subnets_vertical_1.*.id == null ? [] : aws_subnet.private_subnets_vertical_1.*.id
}
output "private_subnets_vertical_1_cidr" {
  value = aws_subnet.private_subnets_vertical_1.*.cidr_block == null ? [] : aws_subnet.private_subnets_vertical_1.*.cidr_block
}
output "private_subnets_vertical_2_id" {
  value = aws_subnet.private_subnets_vertical_2.*.id == null ? [] : aws_subnet.private_subnets_vertical_2.*.id
}
output "private_subnets_vertical_2_cidr" {
  value = aws_subnet.private_subnets_vertical_2.*.cidr_block == null ? [] : aws_subnet.private_subnets_vertical_2.*.cidr_block
}
output "private_subnets_vertical_3_id" {
  value = aws_subnet.private_subnets_vertical_3.*.id == null ? [] : aws_subnet.private_subnets_vertical_3.*.id
}
output "private_subnets_vertical_3_cidr" {
  value = aws_subnet.private_subnets_vertical_3.*.cidr_block == null ? [] : aws_subnet.private_subnets_vertical_3.*.cidr_block
}
#private horizontal
output "private_subnets_horizontal_1_id" {
  value = aws_subnet.private_subnets_horizontal_1.*.id == null ? [] : aws_subnet.private_subnets_horizontal_1.*.id
}
output "private_subnets_horizontal_1_cidr" {
  value = aws_subnet.private_subnets_horizontal_1.*.cidr_block == null ? [] : aws_subnet.private_subnets_horizontal_1.*.cidr_block
}
output "private_subnets_horizontal_2_id" {
  value = aws_subnet.private_subnets_horizontal_2.*.id == null ? [] : aws_subnet.private_subnets_horizontal_2.*.id
}
output "private_subnets_horizontal_2_cidr" {
  value = aws_subnet.private_subnets_horizontal_2.*.cidr_block == null ? [] : aws_subnet.private_subnets_horizontal_2.*.cidr_block
}
output "private_subnets_horizontal_3_id" {
  value = aws_subnet.private_subnets_horizontal_3.*.id == null ? [] : aws_subnet.private_subnets_horizontal_3.*.id
}
output "private_subnets_horizontal_3_cidr" {
  value = aws_subnet.private_subnets_horizontal_3.*.cidr_block == null ? [] : aws_subnet.private_subnets_horizontal_3.*.cidr_block
}
#public nat gateway
output "public_subnets_nat_id" {
  value = aws_subnet.public_subnets_nat.*.id == null ? [] : aws_subnet.public_subnets_nat.*.id
}
output "public_subnets_nat_cidr" {
  value = aws_subnet.public_subnets_nat.*.cidr_block == null ? [] : aws_subnet.public_subnets_nat.*.cidr_block
}
#public
output "public_subnets_id" {
  value = aws_subnet.public_subnets.*.id == null ? [] : aws_subnet.public_subnets.*.id
}
output "public_subnets_cidr" {
  value = aws_subnet.public_subnets.*.cidr_block == null ? [] : aws_subnet.public_subnets.*.cidr_block
}
#public igw edge
output "public_subnets_edge_id" {
  value = aws_subnet.public_subnets_edge.*.id == null ? [] : aws_subnet.public_subnets_edge.*.id
}
output "public_subnets_edge_cidr" {
  value = aws_subnet.public_subnets_edge.*.cidr_block == null ? [] : aws_subnet.public_subnets_edge.*.cidr_block
}

# Output variables for the route tables
# Isolated private route table id
output "route_tables_id_private_subnets_isolated" {
  value = aws_route_table.private_subnets_isolated.*.id == null ? [] : aws_route_table.private_subnets_isolated.*.id
}
#nat private route table id
output "route_tables_id_private_subnets_nat" {
  value = aws_route_table.private_subnets_nat.*.id == null ? [] : aws_route_table.private_subnets_nat.*.id
}
#vertical private route table id
output "route_tables_id_private_subnets_vertical_1" {
  value = aws_route_table.private_subnets_vertical_1.*.id == null ? [] : aws_route_table.private_subnets_vertical_1.*.id
}
output "route_tables_id_private_subnets_vertical_2" {
  value = aws_route_table.private_subnets_vertical_2.*.id == null ? [] : aws_route_table.private_subnets_vertical_2.*.id
}
output "route_tables_id_private_subnets_vertical_3" {
  value = aws_route_table.private_subnets_vertical_3.*.id == null ? [] : aws_route_table.private_subnets_vertical_3.*.id
}
#horizontal private route table id
output "route_tables_id_private_subnets_horizontal_1" {
  value = aws_route_table.private_subnets_horizontal_1.*.id == null ? [] : aws_route_table.private_subnets_horizontal_1.*.id
}
output "route_tables_id_private_subnets_horizontal_2" {
  value = aws_route_table.private_subnets_horizontal_2.*.id == null ? [] : aws_route_table.private_subnets_horizontal_2.*.id
}
output "route_tables_id_private_subnets_horizontal_3" {
  value = aws_route_table.private_subnets_horizontal_3.*.id == null ? [] : aws_route_table.private_subnets_horizontal_3.*.id
}
#public nat gateway route table id
output "route_tables_id_public_subnets_nat" {
  value = aws_route_table.public_subnets_nat.*.id == null ? [] : aws_route_table.public_subnets_nat.*.id
}
#public route table ids
output "route_tables_id_public_subnets" {
  value = aws_route_table.public_subnets.*.id == null ? [] : aws_route_table.public_subnets.*.id
}
#edge public route table ids
output "route_tables_id_public_subnets_edge" {
  value = aws_route_table.public_subnets_edge.*.id == null ? [] : aws_route_table.public_subnets_edge.*.id
}

#id de los nat gateways 
output "nat_gateway_id_nat_gateway" {
  value = aws_nat_gateway.nat_gateway.*.id == null ? [] : aws_nat_gateway.nat_gateway.*.id
}
#id del internet gateway 
output "internet_gateway_id_igw_dc" {
  value = aws_internet_gateway.igw_dc.*.id == null ? [] : aws_internet_gateway.igw_dc.*.id
}

output "public_subnet_ids" {
  description = "IDs de todas las subredes públicas (alias de public_subnets_id)"
  value       = aws_subnet.public_subnets[*].id
}

output "private_subnet_ids" {
  description = "IDs de las subredes privadas aisladas (usadas por ASG y RDS)"
  value       = aws_subnet.private_subnets_isolated[*].id
}