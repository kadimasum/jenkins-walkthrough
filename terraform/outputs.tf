# Root outputs - aggregate module outputs

# S3 Outputs
output "s3_bucket_id" {
  description = "S3 bucket ID"
  value       = module.s3.bucket_id
}

output "s3_bucket_arn" {
  description = "S3 bucket ARN"
  value       = module.s3.bucket_arn
}

# CloudFront Outputs
output "cloudfront_distribution_id" {
  description = "CloudFront Distribution ID for cache invalidation"
  value       = module.cloudfront.distribution_id
}

output "cloudfront_domain_name" {
  description = "CloudFront domain name (use for accessing the site)"
  value       = module.cloudfront.distribution_domain_name
}

output "site_url" {
  description = "Complete URL to access the deployed site"
  value       = "https://${module.cloudfront.distribution_domain_name}"
}

output "cloudfront_distribution_arn" {
  description = "CloudFront Distribution ARN"
  value       = module.cloudfront.distribution_arn
}

# IAM Outputs
output "iam_user_name" {
  description = "IAM user name for Jenkins deployment"
  value       = module.iam.iam_user_name
}

output "jenkins_access_key_id" {
  description = "AWS Access Key ID for Jenkins (store securely, do not commit)"
  value       = module.iam.access_key_id
  sensitive   = true
}

output "jenkins_secret_access_key" {
  description = "AWS Secret Access Key for Jenkins (store securely, do not commit)"
  value       = module.iam.secret_access_key
  sensitive   = true
}

output "deployment_info" {
  description = "Summary of deployed infrastructure"
  value = {
    s3_bucket          = module.s3.bucket_id
    cloudfront_domain  = module.cloudfront.distribution_domain_name
    site_url           = "https://${module.cloudfront.distribution_domain_name}"
    jenkins_user       = module.iam.iam_user_name
    cloudfront_dist_id = module.cloudfront.distribution_id
    instructions       = "Store the jenkins_access_key_id and jenkins_secret_access_key securely in Jenkins credentials"
  }
}
