resource "aws_vpc_endpoint" "vpce_s3" {
  vpc_id       = data.terraform_remote_state.vpc_core.outputs.vpc_id
  service_name = "com.amazonaws.${var.aws_region}.s3"
  route_table_ids = [
    data.terraform_remote_state.vpc_core.outputs.private_route_table_1_id,
    data.terraform_remote_state.vpc_core.outputs.private_route_table_2_id,
    data.terraform_remote_state.vpc_core.outputs.private_route_table_3_id,
    data.terraform_remote_state.vpc_core.outputs.db_route_table_1_id,
    data.terraform_remote_state.vpc_core.outputs.db_route_table_2_id,
    data.terraform_remote_state.vpc_core.outputs.db_route_table_3_id,
  ]

  tags = merge(
    var.common_tags,
    {
      Name   = "${var.resource_prefix}-vpce-s3"
      Module = "01-networking/02-vpc-endpoints"
    },
  )
}
