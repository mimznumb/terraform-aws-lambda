import json
import boto3
import os

def handler(event, context):
    """
    Lambda function that retrieves a secret from AWS Secrets Manager.
    Expects SECRET_ARN environment variable.
    """
    secret_arn = os.environ.get('SECRET_ARN')
    
    if not secret_arn:
        return {
            'statusCode': 400,
            'body': json.dumps({
                'error': 'SECRET_ARN environment variable not set'
            })
        }
    
    try:
        # Create Secrets Manager client
        client = boto3.client('secretsmanager')
        
        # Retrieve the secret
        response = client.get_secret_value(SecretId=secret_arn)
        
        # Get the secret string
        secret_value = response['SecretString']
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Secret retrieved successfully',
                'secret': secret_value
            })
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': str(e)
            })
        }
