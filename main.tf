# ───────────────────────────────────────────────────────────────────────────
# Interview Intelligence Platform — Terraform root
# ───────────────────────────────────────────────────────────────────────────

terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket = "ai-interview-coach"
    key    = "terraform.tfstate"
    region = "us-east-2"
  }
}

provider "aws" {
  region = var.aws_region
}

# ── Networking ──────────────────────────────────────────────────────────
module "networking" {
  source = "./modules/networking"

  name           = var.name
  vpc_cidr       = var.vpc_cidr
  public_subnets = var.public_subnets
}

# ── Secrets ─────────────────────────────────────────────────────────────
module "secrets" {
  source = "./modules/secrets"

  name = var.name
}

# ── S3 (transcript bucket) ──────────────────────────────────────────────
module "s3" {
  source = "./modules/s3"

  bucket_name = var.transcript_bucket
}

# ── SQS (EventBridge target) ────────────────────────────────────────────
module "sqs" {
  source = "./modules/sqs"

  name = var.name
}

# ── EventBridge (S3 → SQS) ──────────────────────────────────────────────
module "eventbridge" {
  source = "./modules/eventbridge"

  name           = var.name
  s3_bucket_name = module.s3.bucket_name
  sqs_queue_arn  = module.sqs.queue_arn
}

# ── RDS PostgreSQL ──────────────────────────────────────────────────────
module "rds" {
  source = "./modules/rds"

  name              = var.name
  subnet_ids        = module.networking.public_subnet_ids
  security_group_id = module.networking.default_sg_id
  db_name           = var.db_name
  db_username       = var.db_username
  db_password       = var.db_password
  instance_class    = var.db_instance_class
}

# ── ECR ─────────────────────────────────────────────────────────────────
module "ecr" {
  source = "./modules/ecr"

  name = var.name
}

# ── IAM ─────────────────────────────────────────────────────────────────
module "iam" {
  source = "./modules/iam"

  name                  = var.name
  transcript_bucket     = module.s3.bucket_arn
  sqs_queue_arn         = module.sqs.queue_arn
  ecr_repo_arn          = module.ecr.repo_arn
  rds_arn               = module.rds.db_arn
  db_password_secret    = module.secrets.db_password_secret_arn
  deepseek_secret       = module.secrets.deepseek_secret_arn
  inngest_event_key_arn = module.secrets.inngest_event_key_arn
  inngest_signing_key_arn = module.secrets.inngest_signing_key_arn
  database_url_arn      = module.secrets.database_url_arn
}

# ── ECS Fargate ─────────────────────────────────────────────────────────
module "ecs" {
  source = "./modules/ecs"

  name                   = var.name
  subnet_ids             = module.networking.public_subnet_ids
  security_group_id      = module.networking.default_sg_id
  ecr_api_url            = module.ecr.api_repo_url
  ecr_worker_url         = module.ecr.worker_repo_url
  execution_role_arn     = module.iam.execution_role_arn
  task_role_arn          = module.iam.task_role_arn
  db_host                = module.rds.db_host
  db_name                = var.db_name
  db_username            = var.db_username
  db_password_secret     = module.secrets.db_password_secret_arn
  deepseek_secret        = module.secrets.deepseek_secret_arn
  inngest_event_key_arn  = module.secrets.inngest_event_key_arn
  inngest_signing_key_arn = module.secrets.inngest_signing_key_arn
  database_url_arn       = module.secrets.database_url_arn
  sqs_queue_url          = module.sqs.queue_url
}

# ── CloudWatch ──────────────────────────────────────────────────────────
module "cloudwatch" {
  source = "./modules/cloudwatch"

  name               = var.name
  ecs_cluster_name   = module.ecs.cluster_name
  ecs_api_service    = module.ecs.api_service_name
  ecs_worker_service = module.ecs.worker_service_name
}
