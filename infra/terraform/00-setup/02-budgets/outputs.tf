output "monthly_budget_id" {
  description = "ID of the monthly budget"
  value       = aws_budgets_budget.monthly.id
}

output "monthly_budget_arn" {
  description = "ARN of the monthly budget"
  value       = aws_budgets_budget.monthly.arn
}

output "daily_budget_id" {
  description = "ID of the daily budget"
  value       = aws_budgets_budget.daily.id
}

output "daily_budget_arn" {
  description = "ARN of the daily budget"
  value       = aws_budgets_budget.daily.arn
}
