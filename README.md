# Grange: Citrus Fruit Classification

An end-to-end machine learning project that classifies citrus fruits (oranges and grapefruits) based on their physical measurements using a Decision Tree classifier. The project includes infrastructure as code for deploying the model on AWS SageMaker with a serverless API endpoint.

## Features

- **Machine Learning**
  - Loads and preprocesses citrus fruit data
  - Trains a Decision Tree classifier
  - Evaluates model performance (94%+ accuracy)
  - Makes predictions on new samples

- **Infrastructure (AWS)**
  - Automated model training pipeline with SageMaker
  - Containerized training and inference
  - Serverless API endpoint with API Gateway
  - Lambda functions for model deployment
  - IAM roles and policies
  - S3 bucket for data storage and model artifacts
  - ECR repositories for Docker images

## Dataset

The dataset (`citrus.csv`) contains the following columns:
- `name`: Fruit type (orange or grapefruit)
- `diameter`: Fruit diameter
- `weight`: Fruit weight
- `red`, `green`, `blue`: Color components (0-255)

Source: [Kaggle: Oranges vs Grapefruit](https://www.kaggle.com/datasets/joshmcadams/oranges-vs-grapefruit)

## Prerequisites
- Python 3.8+
- AWS CLI configured with appropriate credentials
- Terraform v1.0+
- Docker

## Local Development

### Setup

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd grange
   ```

2. Create and activate a virtual environment:
   ```bash
   python -m venv venv
   source venv/bin/activate  # Linux/Mac
   # OR
   .\venv\Scripts\activate  # Windows
   ```

3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

### Local Training

To train the model locally:
```bash
python main.py
```

This will:
- Load and preprocess the data
- Train the model
- Print the test accuracy
- Make a sample prediction

## AWS Deployment

The infrastructure is managed using Terraform. The deployment includes:
- SageMaker training pipeline
- Model endpoints
- API Gateway
- Lambda to deploy models
- S3 buckets for data storage
- IAM roles and policies

### Deploying to AWS

1. Initialize Terraform:
   ```bash
   cd terraform
   terraform init
   ```

2. Review the execution plan:
   ```bash
   terraform plan
   ```

3. Apply the configuration:
   ```bash
   terraform apply
   ```

## API Usage

Once deployed, you can make predictions by sending a POST request to the API Gateway endpoint:

```bash
curl -X POST https://<api-gateway-url>/predict \
  -H "Content-Type: application/json" \
  -d '{"instances": [
    {
      "diameter": 11.0,
      "weight": 120.5,
      "red": 200,
      "green": 150,
      "blue": 100
    },
    {
      "diameter": 3.8,
      "weight": 80.2,
      "red": 120,
      "green": 180,
      "blue": 220
    }
  ]
}'
```

## CI/CD

The project includes GitHub Actions workflows for:
- Automated testing
- Container image building and pushing to ECR

## Cleanup

To destroy all AWS resources:

```bash
cd terraform
terraform destroy
```
