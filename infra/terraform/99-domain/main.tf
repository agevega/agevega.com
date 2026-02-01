resource "aws_route53_zone" "main" {
  name = var.domain_name

  tags = merge(var.common_tags, {
    Name = var.domain_name
  })
}

# ------------------------------------------------------------------------------
# Alias Records for CloudFront
# ------------------------------------------------------------------------------
resource "aws_route53_record" "dev" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "dev.${var.domain_name}"
  type    = "A"
  
  alias {
    name                   = data.terraform_remote_state.bastion_cloudfront.outputs.cloudfront_domain_name
    zone_id                = "Z2FDTNDATAQYW2" # Zone ID fijo para CloudFront
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "root" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = data.terraform_remote_state.prod_cloudfront.outputs.cloudfront_domain_name
    zone_id                = "Z2FDTNDATAQYW2" # Zone ID fijo para CloudFront
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "www.${var.domain_name}"
  type    = "A"

  alias {
    name                   = data.terraform_remote_state.prod_cloudfront.outputs.cloudfront_domain_name
    zone_id                = "Z2FDTNDATAQYW2" # Zone ID fijo para CloudFront
    evaluate_target_health = false
  }
}

# ------------------------------------------------------------------------------
# ACM Validation Records (Dynamic)
# ------------------------------------------------------------------------------
resource "aws_route53_record" "acm_validation" {
  for_each = {
    for dvo in data.terraform_remote_state.acm.outputs.certificate_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.main.zone_id
}
