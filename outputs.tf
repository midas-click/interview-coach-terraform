output "vpc_id" { value = module.networking.vpc_id }
output "db_endpoint" { value = module.rds.db_host }
output "sqs_queue_url" { value = module.sqs.queue_url }
output "s3_bucket" { value = module.s3.bucket_name }
output "ecs_cluster" { value = module.ecs.cluster_name }
