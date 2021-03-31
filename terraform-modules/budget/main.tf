
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider aws {
  region = var.region
}

resource aws_budgets_budget dev_budget {
  name = "dev-budget"
  budget_type = "COST"
  limit_amount = "10"
  limit_unit = "USD"
  time_period_end = "2030-01-01_00:00"
  time_period_start = "2021-03-01_00:00"
  time_unit = "MONTHLY"

  notification {
    comparison_operator = "GREATER_THAN"
    threshold = 100
    threshold_type = "PERCENTAGE"
    notification_type = "FORECASTED"
    subscriber_email_addresses = [ var.email_address ]
  }
}


