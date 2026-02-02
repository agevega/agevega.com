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
  zone_id         = data.terraform_remote_state.dns_zone.outputs.zone_id
}
