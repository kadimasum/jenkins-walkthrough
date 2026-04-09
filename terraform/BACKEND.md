# Terraform Backend Configuration

## Current Setup: Local Backend

This project uses a **local backend** for Terraform state management. The state file is stored locally on disk.

### State File Location
```
terraform/terraform.tfstate
```

### Configuration
In `main.tf`:
```hcl
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}
```

## Understanding Terraform State

The state file (`terraform.tfstate`) stores:
- Resource IDs and attributes created by Terraform
- Mapping between Terraform code and real AWS resources
- Current infrastructure configuration

**Never commit state files to Git** - they contain sensitive data (AWS credentials, passwords, etc.). The `.gitignore` already excludes them.

## Local Backend Advantages

✅ **Zero Setup** - No additional infrastructure required  
✅ **Simple** - Works immediately without configuration  
✅ **Good for Development** - Perfect for local testing and learning  
✅ **Offline** - Doesn't require external services  

### Disadvantages for Team/Production

❌ **Not Shared** - Can't be accessed by other team members  
❌ **No Locking** - Multiple users can run terraform apply simultaneously (causes conflicts)  
❌ **No Versioning** - No history of state changes  
❌ **Machine-Specific** - Lost if your machine is destroyed  

## For Classroom Demonstration

The local backend is **perfect** for:
- Individual student systems
- Live demos showing Terraform provisioning
- Learning Terraform fundamentals
- Testing infrastructure code
- Small projects

## Migrating to Remote Backend

When you need team collaboration or production deployment, migrate to a remote backend:

### Option 1: AWS S3 Backend

```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "devops13-studio/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

**Advantages:**
- ✅ Team accessible
- ✅ Encrypted storage
- ✅ State locking with DynamoDB
- ✅ Versioning enabled
- ✅ Cost-effective

### Option 2: Terraform Cloud

```hcl
terraform {
  cloud {
    organization = "my-org"
    
    workspaces {
      name = "devops13-studio"
    }
  }
}
```

**Advantages:**
- ✅ Managed by HashiCorp
- ✅ Free tier available
- ✅ Web UI for state management
- ✅ Team collaboration built-in
- ✅ Run history and approvals

## Backend State Locking

When using remote backends with locking (S3 + DynamoDB):

Enable it with:
```hcl
backend "s3" {
  dynamodb_table = "terraform-locks"  # Prevents concurrent applies
}
```

## Migrating State Between Backends

### From Local to S3

1. **Create S3 bucket and DynamoDB table** (for locking)

2. **Add S3 backend config** to `main.tf`

3. **Initialize and migrate:**
   ```bash
   terraform init
   # Terraform will prompt to migrate state
   ```

### Backup State Before Migration
```bash
cp terraform/terraform.tfstate terraform/terraform.tfstate.backup
```

## State File Best Practices

✅ **Never commit state files to Git**  
✅ **Use VCS ignore files** (.gitignore)  
✅ **Regular backups** of state files  
✅ **Encrypt state at rest** (S3 with encryption)  
✅ **Enable state locking** (prevent concurrent modifications)  
✅ **Restrict access** (IAM policies for S3 backends)  
✅ **Remove sensitive data** before sharing code examples  

## Troubleshooting

### State File Corrupted
```bash
# Restore from backup
cp terraform/terraform.tfstate.backup terraform/terraform.tfstate
terraform refresh
```

### State Out of Sync with AWS
```bash
# Refresh state from AWS
terraform refresh

# Then plan to see differences
terraform plan
```

### Accidentally Deleted State
```bash
# If resources still exist in AWS:
terraform import aws_s3_bucket.site <bucket-name>
terraform import aws_cloudfront_distribution.site <distribution-id>
# Rebuild state by importing existing resources
```

### Backend Already Initialized
If you change the backend configuration:
```bash
terraform init -migrate-state
# or
terraform init -reconfigure
```

## For Your Class

**Show students:**

1. **State file location**: `ls -la terraform.tfstate`
2. **State contents**: `cat terraform.tfstate | jq '.' | head -50`
3. **Resource tracking**: Show how Terraform knows which AWS resources it created
4. **Lock demonstration** (if using S3): Show DynamoDB lock table during `terraform apply`
5. **Team workflow**: Explain why teams need remote backends with locking

## Additional Resources

- [Terraform State Documentation](https://www.terraform.io/language/state)
- [S3 Backend Configuration](https://www.terraform.io/language/settings/backends/s3)
- [Terraform Cloud Documentation](https://www.terraform.io/cloud-docs)
- [State Locking](https://www.terraform.io/language/state/locking)
