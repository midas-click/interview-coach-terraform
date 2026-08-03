resource "aws_db_subnet_group" "main" {
  name       = var.name
  subnet_ids = var.subnet_ids
}

resource "aws_db_instance" "postgres" {
  identifier             = var.name
  engine                 = "postgres"
  engine_version         = "16"
  instance_class         = var.instance_class
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  allocated_storage      = 20
  storage_encrypted      = true
  skip_final_snapshot    = false
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.security_group_id]
}
