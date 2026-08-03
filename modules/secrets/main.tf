resource "aws_secretsmanager_secret" "db_password" {
  name = "${var.name}-db-password"
}

resource "aws_secretsmanager_secret" "deepseek_api_key" {
  name = "${var.name}-deepseek-api-key"
}
