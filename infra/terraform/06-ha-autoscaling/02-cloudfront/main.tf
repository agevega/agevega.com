resource "aws_cloudfront_distribution" "prod_distribution" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Production Distribution for ${var.domain_name}"
  
  web_acl_id = data.terraform_remote_state.waf.outputs.web_acl_arn

  # aliases = ["prod.${var.domain_name}"] # Uncomment when ready

  origin {
    domain_name = data.terraform_remote_state.main.outputs.alb_dns_name
    origin_id   = "ALB-Prod"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "ALB-Prod"
    
    forwarded_values {
      query_string = true
      headers      = ["Host", "Origin", "Authorization"]

      cookies {
        forward = "all"
      }
    }
    
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
    compress               = true
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = data.terraform_remote_state.acm.outputs.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = var.common_tags
}
