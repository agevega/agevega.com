locals {
  cloudfront_domain_name_landing = var.dev_cloudfront ? data.terraform_remote_state.dev_cloudfront.outputs.cloudfront_domain_name_landing : data.terraform_remote_state.prod_cloudfront.outputs.cloudfront_domain_name_landing
  cloudfront_domain_name_academy = var.dev_cloudfront ? data.terraform_remote_state.dev_cloudfront.outputs.cloudfront_domain_name_academy : data.terraform_remote_state.prod_cloudfront.outputs.cloudfront_domain_name_academy
}

resource "aws_route53_record" "landing_root" {
  zone_id = data.terraform_remote_state.dns_zone.outputs.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = local.cloudfront_domain_name_landing
    zone_id                = "Z2FDTNDATAQYW2" # Zone ID fijo para CloudFront
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "landing_www" {
  zone_id = data.terraform_remote_state.dns_zone.outputs.zone_id
  name    = "www.${var.domain_name}"
  type    = "A"

  alias {
    name                   = local.cloudfront_domain_name_landing
    zone_id                = "Z2FDTNDATAQYW2" # Zone ID fijo para CloudFront
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "academy_root" {
  zone_id = data.terraform_remote_state.dns_zone.outputs.zone_id
  name    = "academy.${var.domain_name}"
  type    = "A"

  alias {
    name                   = local.cloudfront_domain_name_academy
    zone_id                = "Z2FDTNDATAQYW2" # Zone ID fijo para CloudFront
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "academy_www" {
  zone_id = data.terraform_remote_state.dns_zone.outputs.zone_id
  name    = "www.academy.${var.domain_name}"
  type    = "A"

  alias {
    name                   = local.cloudfront_domain_name_academy
    zone_id                = "Z2FDTNDATAQYW2" # Zone ID fijo para CloudFront
    evaluate_target_health = false
  }
}
