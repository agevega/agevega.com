resource "aws_wafv2_web_acl" "main" {
  name        = "${var.project_name}-waf-cloudfront"
  description = "WAF for CloudFront distribution protection"
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.project_name}-waf-cloudfront"
    sampled_requests_enabled   = true
  }

  # AWS Managed Rules - Core Rule Set
  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 10

    override_action {
      none {} # Use default action configured in the rule group
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  tags = var.common_tags
}
