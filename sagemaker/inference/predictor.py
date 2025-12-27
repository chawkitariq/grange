"""
Flask application that implements the /ping and /invocations endpoints
required by SageMaker.
"""
import os
import json
import flask
import joblib
import pandas as pd
import logging
from marshmallow import Schema, fields, ValidationError

app = flask.Flask(__name__)
model = None
model_path = '/opt/ml/model/model.joblib'

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class InstanceSchema(Schema):
    diameter = fields.Float(required=True)
    weight = fields.Float(required=True)
    red = fields.Float(required=True)
    green = fields.Float(required=True)
    blue = fields.Float(required=True)

class InputSchema(Schema):
    instances = fields.List(fields.Nested(InstanceSchema), required=True)

def load_model():
    """Load the model from the model directory"""
    global model
    if os.path.exists(model_path):
        model = joblib.load(model_path)
        logger.info(f"Model loaded successfully from {model_path}")
        return True
    else:
        logger.error(f"Model file not found at {model_path}")
        return False

if not load_model():
    raise RuntimeError("Model file missing. Cannot start inference service.")

@app.route('/ping', methods=['GET'])
def ping():
    """
    Health check endpoint - required by SageMaker.
    Returns 200 if model is loaded and ready.
    """
    health = model is not None
    status = 200 if health else 500
    return flask.Response(response='\n', status=status, mimetype='application/json')

@app.route('/invocations', methods=['POST'])
def invocations():
    """
    Inference endpoint - required by SageMaker.
    Expects strictly:  
        {"instances": [
            {"diameter": ..., "weight": ..., "red": ..., "green": ..., "blue": ...},
            ...
        ]}
    """
    if model is None:
        return flask.Response(
            response=json.dumps({'error': 'Model not loaded'}),
            status=500,
            mimetype='application/json'
        )
    
    try:
        if flask.request.content_type != 'application/json':
            return flask.Response(
                response=json.dumps({'error': 'Unsupported content type'}),
                status=415,
                mimetype='application/json'
            )
        
        input_json = flask.request.get_json()
        if not input_json:
            return flask.Response(
                response=json.dumps({'error': 'Empty request body'}),
                status=400,
                mimetype='application/json'
            )
        
        schema = InputSchema()
        try:
            validated = schema.load(input_json)
        except ValidationError as err:
            logger.warning(f"Validation error: {err.messages}")
            return flask.Response(
                response=json.dumps({'error': 'Invalid input format', 'details': err.messages}),
                status=400,
                mimetype='application/json'
            )
        
        data = pd.DataFrame(validated['instances'])
        
        predictions = model.predict(data)
        result = {'predictions': predictions.tolist()}
        
        if hasattr(model, 'predict_proba'):
            probabilities = model.predict_proba(data)
            result['probabilities'] = probabilities.tolist()
        
        return flask.Response(
            response=json.dumps(result),
            status=200,
            mimetype='application/json'
        )
        
    except Exception as e:
        logger.error("Error during inference", exc_info=True)
        return flask.Response(
            response=json.dumps({'error': 'Internal server error'}),
            status=500,
            mimetype='application/json'
        )
