locals {
  origin_id    = "EC2-${data.terraform_remote_state.bastion_eip.outputs.eip_public_ip}"
  s3_origin_id = "S3-Assets"
}

resource "aws_cloudfront_origin_access_control" "s3_oac" {
  name                              = "s3-assets-oac"
  description                       = "OAC for S3 Assets"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "distribution" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Distribution for ${var.domain_name}"
  default_root_object = "" # Not needed for proxy to EC2
  
  # Auto-attach WAF if module 02 is deployed. Gracefully fallback to null (no WAF) if state is missing.
  web_acl_id = try(data.terraform_remote_state.waf.outputs.web_acl_arn, null)

  aliases = [var.domain_name, "www.${var.domain_name}"]

  origin {
    domain_name = data.terraform_remote_state.bastion_eip.outputs.eip_public_dns
    origin_id   = local.origin_id

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only" # Connect to EC2 via HTTP (Port 80)
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  origin {
    domain_name              = data.terraform_remote_state.s3_assets.outputs.assets_bucket_regional_domain_name
    origin_id                = local.s3_origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.s3_oac.id
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.origin_id
    
    forwarded_values {
      query_string = true
      headers      = ["Host", "Origin"] # Important for Nginx and CORS

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

  ordered_cache_behavior {
    path_pattern     = "/assets/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false
      headers      = ["Origin", "Access-Control-Request-Method", "Access-Control-Request-Headers"]

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_100" # Use PriceClass_100 (USA/Europe) to minimize cost as requested

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
