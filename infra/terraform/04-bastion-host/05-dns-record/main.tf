resource "aws_route53_record" "dev_landing" {
  zone_id = data.terraform_remote_state.dns_zone.outputs.zone_id
  name    = "dev.${var.domain_name}"
  type    = "A"

  alias {
    name                   = data.terraform_remote_state.bastion_cloudfront.outputs.cloudfront_domain_name_landing
    zone_id                = "Z2FDTNDATAQYW2" # Zone ID fijo para CloudFront
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "dev_academy" {
  zone_id = data.terraform_remote_state.dns_zone.outputs.zone_id
  name    = "dev.academy.${var.domain_name}"
  type    = "A"

  alias {
    name                   = data.terraform_remote_state.bastion_cloudfront.outputs.cloudfront_domain_name_academy
    zone_id                = "Z2FDTNDATAQYW2" # Zone ID fijo para CloudFront
    evaluate_target_health = false
  }
}
