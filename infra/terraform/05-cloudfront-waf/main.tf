# ------------------------------------------------------------------------------
# ACM Certificate (Global/US-East-1)
# ------------------------------------------------------------------------------
resource "aws_acm_certificate" "cert" {
  provider          = aws.us_east_1
  domain_name       = var.domain_name
  subject_alternative_names = ["www.${var.domain_name}"]
  validation_method = "DNS"

  tags = var.common_tags

  lifecycle {
    create_before_destroy = true
  }
}

# ------------------------------------------------------------------------------
# WAFWebACL (Global/US-East-1) - DISABLED FOR COST SAVINGS (~$6/month)
# ------------------------------------------------------------------------------
# resource "aws_wafv2_web_acl" "main" {
#   provider    = aws.us_east_1
#   name        = "${var.project_name}-waf-cloudfront"
#   description = "WAF for CloudFront distribution protection"
#   scope       = "CLOUDFRONT"
#
#   default_action {
#     allow {}
#   }
#
#   visibility_config {
#     cloudwatch_metrics_enabled = true
#     metric_name                = "${var.project_name}-waf-cloudfront"
#     sampled_requests_enabled   = true
#   }
#
#   # AWS Managed Rules - Core Rule Set
#   rule {
#     name     = "AWS-AWSManagedRulesCommonRuleSet"
#     priority = 10
#
#     override_action {
#       none {} # Use default action configured in the rule group
#     }
#
#     statement {
#       managed_rule_group_statement {
#         name        = "AWSManagedRulesCommonRuleSet"
#         vendor_name = "AWS"
#       }
#     }
#
#     visibility_config {
#       cloudwatch_metrics_enabled = true
#       metric_name                = "AWS-AWSManagedRulesCommonRuleSet"
#       sampled_requests_enabled   = true
#     }
#   }
#
#   tags = var.common_tags
# }



# ------------------------------------------------------------------------------
# CloudFront Distribution
# ------------------------------------------------------------------------------
locals {
  origin_id = "EC2-${data.terraform_remote_state.security.outputs.eip_public_ip}"
}

resource "aws_cloudfront_distribution" "distribution" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Distribution for ${var.domain_name}"
  default_root_object = "" # Not needed for proxy to EC2
  # web_acl_id          = aws_wafv2_web_acl.main.arn # DISABLED for cost savings

  aliases = [var.domain_name, "www.${var.domain_name}"]

  origin {
    domain_name = data.terraform_remote_state.security.outputs.eip_public_dns
    origin_id   = local.origin_id

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only" # Connect to EC2 via HTTP (Port 80)
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.origin_id
    
    forwarded_values {
      query_string = true
      headers      = ["Host", "Origin"] # Importante para Nginx y CORS

      cookies {
        forward = "none"
      }
    }
    
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
  }

  price_class = "PriceClass_100" # Use PriceClass_100 (USA/Europe) to minimize cost as requested

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = var.common_tags
}
