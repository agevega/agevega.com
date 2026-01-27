import json
import boto3
import os
import logging
from botocore.exceptions import ClientError

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize SES client
ses_client = boto3.client('ses', region_name=os.environ['SES_REGION'])

def lambda_handler(event, context):
    logger.info("Received event: %s", json.dumps(event))
    


    try:
        # Parse body
        body = json.loads(event.get('body', '{}'))
        
        name = body.get('name')
        email = body.get('email')
        subject = body.get('subject')
        message = body.get('message')
        
        # Validation
        if not all([name, email, subject, message]):
             return {
                'statusCode': 400,
                'body': json.dumps({'error': 'Missing required fields'})
            }

        # Prepare email
        sender = os.environ['SENDER_EMAIL']
        recipient = os.environ['RECIPIENT_EMAIL']
        
        email_subject = f"[Contact Form] {subject}"
        email_body = f"""
New contact form submission from agevega.com:

Name: {name}
Email: {email}
Subject: {subject}

Message:
{message}
        """
        
        # Send email
        response = ses_client.send_email(
            Source=sender,
            Destination={
                'ToAddresses': [recipient]
            },
            Message={
                'Subject': {
                    'Data': email_subject,
                    'Charset': 'UTF-8'
                },
                'Body': {
                    'Text': {
                        'Data': email_body,
                        'Charset': 'UTF-8'
                    }
                }
            },
            ReplyToAddresses=[email]
        )
        
        logger.info("Email sent successfully: %s", response['MessageId'])
        
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json'
            },
            'body': json.dumps({'message': 'Email sent successfully'})
        }

    except ClientError as e:
        logger.error("SES Error: %s", e.response['Error']['Message'])
        return {
            'statusCode': 500,
            'body': json.dumps({'error': 'Failed to send email via SES'})
        }
    except Exception as e:
        logger.error("Internal Error: %s", str(e))
        return {
            'statusCode': 500,
            'body': json.dumps({'error': 'Internal server error'})
        }
