output "endpoint" {
  value = module.iam.endpoint
}

output "worker_node_sg_id" {
  value = module.vpc.sg_id
}

output "s3_bucket_arn" {
  value       = module.state.s3_bucket_arn
  description = "The ARN of the S3 bucket"
}

output "dynamodb_table_name" {
  value       = module.state.dynamodb_table_name
  description = "The name of the DynamoDB table"
}