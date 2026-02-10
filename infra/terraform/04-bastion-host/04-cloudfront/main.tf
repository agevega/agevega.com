locals {
  origin_id    = "EC2-Bastion"
  s3_origin_id = "S3-Assets"
}

resource "aws_cloudfront_origin_access_control" "s3_oac" {
  name                              = "s3-assets-oac-bastion"
  description                       = "OAC for S3 Assets (Bastion)"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "bastion_distribution" {
  enabled         = true
  is_ipv6_enabled = true
  comment         = "Bastion Host Origin (Module 04) - Distribution for dev.${var.domain_name}"

  web_acl_id = var.enable_waf ? data.terraform_remote_state.waf[0].outputs.web_acl_arn : null

  aliases = ["dev.${var.domain_name}"]

  origin {
    domain_name = data.terraform_remote_state.bastion_instance.outputs.bastion_public_dns
    origin_id   = local.origin_id

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
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
      headers      = ["Host", "Origin"]

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
    path_pattern               = "/meta.json"
    allowed_methods            = ["GET", "HEAD", "OPTIONS"]
    cached_methods             = ["GET", "HEAD"]
    target_origin_id           = local.origin_id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.no_cache.id

    forwarded_values {
      query_string = true
      headers      = ["Host", "Origin"]

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
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

resource "aws_cloudfront_response_headers_policy" "no_cache" {
  name    = "bastion-no-cache"
  comment = "Disable browser caching for dynamic paths (Bastion)"

  custom_headers_config {
    items {
      header   = "Cache-Control"
      override = true
      value    = "no-cache, no-store, must-revalidate"
    }
  }
}

resource "aws_ssm_parameter" "cloudfront_distribution_id" {
  name        = "/${var.project_name}/04-bastion-host/04-cloudfront/cloudfront-distribution-id"
  description = "CloudFront Distribution ID (Bastion)"
  type        = "String"
  value       = aws_cloudfront_distribution.bastion_distribution.id

  tags = var.common_tags
}
