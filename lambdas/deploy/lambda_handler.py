"""
Simple Lambda function to deploy SageMaker endpoint
Creates endpoint config and deploys endpoint
"""
import boto3
from datetime import datetime

sagemaker = boto3.client('sagemaker')

def lambda_handler(event, context):
    """Deploy or update a SageMaker endpoint"""
    
    model_name = event['ModelName']
    endpoint_name = event['EndpointName']
    
    timestamp = datetime.now().strftime('%Y%m%d-%H%M%S')
    config_name = f"{endpoint_name}-{timestamp}"
    
    sagemaker.create_endpoint_config(
        EndpointConfigName=config_name,
        ProductionVariants=[{
            'VariantName': 'AllTraffic',
            'ModelName': model_name,
            'ServerlessConfig': {
                'MemorySizeInMB': 2048,
                'MaxConcurrency': 10
            }
        }]
    )
    
    try:
        sagemaker.describe_endpoint(EndpointName=endpoint_name)
        sagemaker.update_endpoint(
            EndpointName=endpoint_name,
            EndpointConfigName=config_name
        )
    except:
        sagemaker.create_endpoint(
            EndpointName=endpoint_name,
            EndpointConfigName=config_name
        )
    
    return {'statusCode': 200, 'body': 'Success'}
    