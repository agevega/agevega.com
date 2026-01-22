resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = merge(
    var.common_tags,
    {
      Name   = "${var.resource_prefix}-nat-eip"
      Module = "01-networking/01-nat-gateway"
    },
  )
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = data.terraform_remote_state.vpc_core.outputs.subnet_public_1_id

  tags = merge(
    var.common_tags,
    {
      Name   = "${var.resource_prefix}-nat-gw"
      Module = "01-networking/01-nat-gateway"
    },
  )
}

resource "aws_route" "private_default_route" {
  for_each               = data.terraform_remote_state.vpc_core.outputs.private_route_table_ids
  route_table_id         = each.value
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw.id
}
