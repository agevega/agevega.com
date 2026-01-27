resource "aws_acm_certificate" "cert" {
  domain_name       = var.domain_name
  subject_alternative_names = ["www.${var.domain_name}", "dev.${var.domain_name}"]
  validation_method = "DNS"

  tags = merge(var.common_tags, {
    Module = "02-shared-resources/01-acm-certificates"
  })

  lifecycle {
    create_before_destroy = true
  }
}
