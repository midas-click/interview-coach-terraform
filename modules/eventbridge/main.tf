resource "aws_cloudwatch_event_rule" "s3_object_created" {
  name        = "${var.name}-s3-object-created"
  description = "Capture S3 ObjectCreated events for interview transcripts"
  event_pattern = jsonencode({
    source      = ["aws.s3"]
    detail-type = ["Object Created"]
    detail = {
      bucket = { name = [var.s3_bucket_name] }
      object = { key = [{ prefix = "interviews/" }] }
    }
  })
}

resource "aws_cloudwatch_event_target" "to_sqs" {
  rule = aws_cloudwatch_event_rule.s3_object_created.name
  arn  = var.sqs_queue_arn
}
