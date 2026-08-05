resource "aws_ecs_cluster" "main" {
  name = var.name
}

# ── API container ───────────────────────────────────────────────────────

resource "aws_ecs_task_definition" "api" {
  family                   = "${var.name}-api"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "2048"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn
  container_definitions = jsonencode([{
    name         = "api"
    image        = var.ecr_api_url
    command      = ["uvicorn", "api.app:app", "--host", "0.0.0.0", "--port", "8000"]
    portMappings = [{ containerPort = 8000 }]
    environment = [
      { name = "ENVIRONMENT",    value = "production" },
      { name = "AWS_REGION",     value = "us-east-2" },
      { name = "INNGEST_DEV",    value = "false" },
      { name = "SQS_QUEUE_URL",  value = var.sqs_queue_url },
      { name = "DEEPSEEK_MODEL", value = "deepseek-chat" },
    ]
    secrets = [
      { name = "DATABASE_URL",        valueFrom = var.database_url_arn },
      { name = "DEEPSEEK_API_KEY",    valueFrom = var.deepseek_secret },
      { name = "INNGEST_EVENT_KEY",   valueFrom = var.inngest_event_key_arn },
      { name = "INNGEST_SIGNING_KEY", valueFrom = var.inngest_signing_key_arn },
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "/ecs/${var.name}-api"
        awslogs-region        = "us-east-2"
        awslogs-stream-prefix = "api"
      }
    }
  }])
}

# ── Worker container (SQS consumer) ─────────────────────────────────────

resource "aws_ecs_task_definition" "worker" {
  family                   = "${var.name}-worker"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn
  container_definitions = jsonencode([{
    name    = "worker"
    image   = var.ecr_worker_url
    command = ["python", "scripts/sqs_consumer.py"]
    environment = [
      { name = "ENVIRONMENT",    value = "production" },
      { name = "AWS_REGION",     value = "us-east-2" },
      { name = "INNGEST_DEV",    value = "false" },
      { name = "SQS_QUEUE_URL",  value = var.sqs_queue_url },
      { name = "DEEPSEEK_MODEL", value = "deepseek-chat" },
    ]
    secrets = [
      { name = "DATABASE_URL",        valueFrom = var.database_url_arn },
      { name = "DEEPSEEK_API_KEY",    valueFrom = var.deepseek_secret },
      { name = "INNGEST_EVENT_KEY",   valueFrom = var.inngest_event_key_arn },
      { name = "INNGEST_SIGNING_KEY", valueFrom = var.inngest_signing_key_arn },
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "/ecs/${var.name}-worker"
        awslogs-region        = "us-east-2"
        awslogs-stream-prefix = "worker"
      }
    }
  }])
}

# ── Services ────────────────────────────────────────────────────────────

resource "aws_ecs_service" "api" {
  name            = "${var.name}-api"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.api.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [var.security_group_id]
    assign_public_ip = true
  }
}

resource "aws_ecs_service" "worker" {
  name            = "${var.name}-worker"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.worker.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [var.security_group_id]
    assign_public_ip = true
  }
}
