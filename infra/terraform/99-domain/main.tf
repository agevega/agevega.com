resource "aws_route53_zone" "main" {
  name = var.domain_name

  tags = merge(var.common_tags, {
    Name = var.domain_name
  })
}

resource "aws_route53_record" "dev" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "dev.${var.domain_name}"
  type    = "CNAME"
  ttl     = 300
  records = [data.terraform_remote_state.bastion_cloudfront.outputs.cloudfront_domain_name]
}
