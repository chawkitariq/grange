import json
import boto3
import os
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

sagemaker_runtime = boto3.client("sagemaker-runtime")

ENDPOINT_NAME = os.environ.get("SAGEMAKER_ENDPOINT_NAME", "grange")

REQUIRED_FIELDS = {"diameter", "weight", "red", "green", "blue"}

def validate_input(data):
    """Validate that input contains required fields."""
    if "instances" in data and isinstance(data["instances"], list):
        for instance in data["instances"]:
            if not REQUIRED_FIELDS.issubset(instance.keys()):
                return False
        return True
    elif REQUIRED_FIELDS.issubset(data.keys()):
        return True
    return False

def lambda_handler(event, context):
    """
    Expects event to be a dict with either:
      - {"instances": [...]} 
      - or a single instance {"diameter": ..., "weight": ..., "red": ..., "green": ..., "blue": ...}
    """
    try:
        input_data = event

        if not input_data or not validate_input(input_data):
            logger.warning(f"Invalid input received: {input_data}")
            return {"error": "Invalid input format"}

        # Ensure payload is in {"instances": [...]} format
        if "instances" not in input_data:
            input_data = {"instances": [input_data]}

        response = sagemaker_runtime.invoke_endpoint(
            EndpointName=ENDPOINT_NAME,
            ContentType="application/json",
            Body=json.dumps(input_data)
        )

        result = json.loads(response["Body"].read().decode())

        return {
            "predictions": result.get("predictions", []),
            "probabilities": result.get("probabilities", []),
        }

    except Exception as e:
        logger.error("Unexpected error occurred", exc_info=True)
        return {"error": "Internal server error"}
