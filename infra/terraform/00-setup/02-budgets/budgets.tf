provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

# ------------------------------------------------------------------------------
# Monthly Budget ($10)
# ------------------------------------------------------------------------------
resource "aws_budgets_budget" "monthly" {
  name              = "My 10$ Budget"
  budget_type       = "COST"
  limit_amount      = var.monthly_budget_amount
  limit_unit        = "USD"
  time_period_start = "2025-10-01_00:00"
  time_unit         = "MONTHLY"

  # Actual > 10% ($1.00)
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 10
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.notification_email]
  }

  # Actual > 50% ($5.00)
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 50
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.notification_email]
  }

  # Actual > 100% ($10.00)
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.notification_email]
  }

  # Forecasted > 200% ($20.00)
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 200
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = [var.notification_email]
  }

  tags = merge(var.common_tags, {
    Name   = "My 10$ Budget"
    Module = "00-setup/02-budgets"
  })
}

# ------------------------------------------------------------------------------
# Daily Budget ($1)
# ------------------------------------------------------------------------------
resource "aws_budgets_budget" "daily" {
  name              = "My Daily 1$ Budget"
  budget_type       = "COST"
  limit_amount      = var.daily_budget_amount
  limit_unit        = "USD"
  time_period_start = "2025-10-26_00:00"
  time_unit         = "DAILY"

  # Actual > 50% ($0.50)
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 50
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.notification_email]
  }

  # Actual > 100% ($1.00)
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.notification_email]
  }

  # Actual > 200% ($2.00)
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 200
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.notification_email]
  }

  # Actual > 500% ($5.00)
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 500
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.notification_email]
  }

  # Actual > 1000% ($10.00)
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 1000
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.notification_email]
  }

  tags = merge(var.common_tags, {
    Name   = "My Daily 1$ Budget"
    Module = "00-setup/02-budgets"
  })
}
