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
# S3 Assets Bucket
# ------------------------------------------------------------------------------
data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "assets" {
  bucket = var.assets_bucket_name
}

resource "aws_s3_bucket_public_access_block" "assets" {
  bucket = aws_s3_bucket.assets.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "assets" {
  bucket = aws_s3_bucket.assets.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_policy" "allow_cloudfront" {
  bucket = aws_s3_bucket.assets.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipal"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.assets.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.distribution.arn
          }
        }
      }
    ]
  })
}

# ------------------------------------------------------------------------------
# CloudFront Distribution
# ------------------------------------------------------------------------------
locals {
  origin_id    = "EC2-${data.terraform_remote_state.security.outputs.eip_public_ip}"
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

  origin {
    domain_name              = aws_s3_bucket.assets.bucket_regional_domain_name
    origin_id                = local.s3_origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.s3_oac.id
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
    acm_certificate_arn      = aws_acm_certificate.cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = var.common_tags
}
