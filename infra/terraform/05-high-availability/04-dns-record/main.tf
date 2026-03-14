locals {
  cloudfront_domain_name = var.dev_cloudfront ? data.terraform_remote_state.dev_cloudfront.outputs.cloudfront_domain_name : data.terraform_remote_state.prod_cloudfront.outputs.cloudfront_domain_name
}

resource "aws_route53_record" "root" {
  zone_id = data.terraform_remote_state.dns_zone.outputs.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = local.cloudfront_domain_name
    zone_id                = "Z2FDTNDATAQYW2" # Zone ID fijo para CloudFront
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www" {
  zone_id = data.terraform_remote_state.dns_zone.outputs.zone_id
  name    = "www.${var.domain_name}"
  type    = "A"

  alias {
    name                   = local.cloudfront_domain_name
    zone_id                = "Z2FDTNDATAQYW2" # Zone ID fijo para CloudFront
    evaluate_target_health = false
  }
}
