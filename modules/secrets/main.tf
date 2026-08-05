resource "aws_secretsmanager_secret" "db_password" {
  name = "${var.name}-db-password"
}

resource "aws_secretsmanager_secret" "deepseek_api_key" {
  name = "${var.name}-deepseek-api-key"
}

resource "aws_secretsmanager_secret" "inngest_event_key" {
  name = "${var.name}-inngest-event-key"
}

resource "aws_secretsmanager_secret" "inngest_signing_key" {
  name = "${var.name}-inngest-signing-key"
}

resource "aws_secretsmanager_secret" "database_url" {
  name = "${var.name}-database-url"
}
