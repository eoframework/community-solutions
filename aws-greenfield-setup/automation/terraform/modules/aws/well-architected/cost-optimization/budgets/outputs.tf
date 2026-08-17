output "budget_id" {
  description = "ID of the AWS Budget"
  value       = aws_budgets_budget.this.id
}

output "budget_name" {
  description = "Name of the AWS Budget"
  value       = aws_budgets_budget.this.name
}
