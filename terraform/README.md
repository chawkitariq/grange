# Terraform Infrastructure as Code

This directory contains Terraform configuration for provisioning and managing AWS infrastructure for the Grange ML project.

## Prerequisites

- AWS CLI configured with credentials
- Terraform (>= 1.0)
- Docker
- Python 3.8+

## Quick Start

1. **Initialize Terraform**
   ```bash
   terraform init \
   -backend-config="bucket=grange-s3-state-backend" \
   -backend-config="key=grange-terraform.tfstate" \
   -backend-config="region=eu-west-3"
   ```

2. **Configure Variables**
   Create `terraform.tfvars` with your settings

3. **Deploy Infrastructure**
   ```bash
   terraform plan
   terraform apply
   ```

## Key Components

- **ECR Repositories**: For Docker images (training and inference)
- **S3 Bucket**: For storing data and model artifacts
- **SageMaker**: For model training and hosting
- **API Gateway & Lambda**: For model inference API
- **CloudWatch**: For logging and monitoring

```bash
terraform destroy
```

**Warning**: This will delete all resources including S3 buckets and their contents!

## Notes

- SageMaker endpoints are created by the SageMaker Pipeline SDK, not Terraform
- ECR repositories are created empty - you need to build and push images
- S3 buckets are created empty - you need to upload training data

