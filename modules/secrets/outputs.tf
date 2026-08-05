output "db_password_secret_arn"    { value = aws_secretsmanager_secret.db_password.arn }
output "deepseek_secret_arn"       { value = aws_secretsmanager_secret.deepseek_api_key.arn }
output "inngest_event_key_arn"     { value = aws_secretsmanager_secret.inngest_event_key.arn }
output "inngest_signing_key_arn"   { value = aws_secretsmanager_secret.inngest_signing_key.arn }
output "database_url_arn"          { value = aws_secretsmanager_secret.database_url.arn }
