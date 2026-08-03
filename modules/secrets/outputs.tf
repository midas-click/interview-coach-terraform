output "db_password_secret_arn" { value = aws_secretsmanager_secret.db_password.arn }
output "deepseek_secret_arn" { value = aws_secretsmanager_secret.deepseek_api_key.arn }
