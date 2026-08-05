variable "name" {
  description = "Project / environment name prefix"
  type        = string
  default     = "interview-intelligence"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnets" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "transcript_bucket" {
  type    = string
  default = "interview-intelligence-transcripts"
}

variable "db_name" {
  type    = string
  default = "interview_intelligence"
}

variable "db_username" {
  type    = string
  default = "interview_admin"
}

variable "db_instance_class" {
  type    = string
  default = "db.t4g.micro"
}

variable "db_password" {
  type      = string
  sensitive = true
  default   = ""
}
