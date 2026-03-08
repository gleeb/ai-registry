# Monitoring & Observability

## Overview

Comprehensive monitoring and observability setup for the Legal Information System using AWS CloudWatch, X-Ray, and other AWS services to ensure system health, performance, and reliability.

## Monitoring Architecture

### Core Components
- **CloudWatch Metrics**: System and custom metrics
- **CloudWatch Logs**: Centralized logging
- **X-Ray**: Distributed tracing
- **CloudWatch Alarms**: Automated alerting
- **CloudWatch Dashboards**: Visual monitoring

## Key Metrics

### API Gateway Metrics
- **Request Count**: Total API requests
- **Latency**: Response time (P50, P95, P99)
- **Error Rate**: 4xx and 5xx errors
- **Integration Latency**: Backend processing time

### Lambda Metrics
- **Invocations**: Function execution count
- **Duration**: Execution time
- **Errors**: Failed invocations
- **Throttles**: Concurrency limit hits
- **Cold Starts**: New container initializations

### Database Metrics
- **CPU Utilization**: Database CPU usage
- **Database Connections**: Active connections
- **Read/Write Latency**: Query performance
- **Storage Usage**: Disk space consumption
- **Replication Lag**: Read replica delay

### Custom Business Metrics
```python
from aws_lambda_powertools import Metrics
from aws_lambda_powertools.metrics import MetricUnit

metrics = Metrics(namespace="TestMeOut", service="API")

@metrics.log_metrics
def handler(event, context):
    # Track chat interactions
    metrics.add_metric(name="ChatMessagesSent", unit=MetricUnit.Count, value=1)
    
    # Track document processing
    metrics.add_metric(name="DocumentsProcessed", unit=MetricUnit.Count, value=1)
    
    # Track user activity
    metrics.add_metric(name="ActiveUsers", unit=MetricUnit.Count, value=user_count)
```

## CloudWatch Dashboards

### Main System Dashboard
```json
{
  "widgets": [
    {
      "type": "metric",
      "properties": {
        "metrics": [
          ["AWS/ApiGateway", "Count", "ApiName", "TestMeOut-API"],
          ["AWS/ApiGateway", "Latency", "ApiName", "TestMeOut-API"],
          ["AWS/ApiGateway", "4XXError", "ApiName", "TestMeOut-API"],
          ["AWS/ApiGateway", "5XXError", "ApiName", "TestMeOut-API"]
        ],
        "period": 300,
        "stat": "Sum",
        "region": "il-central-1",
        "title": "API Gateway Overview"
      }
    },
    {
      "type": "metric",
      "properties": {
        "metrics": [
          ["AWS/Lambda", "Invocations", "FunctionName", "MainApiFunction"],
          ["AWS/Lambda", "Errors", "FunctionName", "MainApiFunction"],
          ["AWS/Lambda", "Duration", "FunctionName", "MainApiFunction"]
        ],
        "period": 300,
        "stat": "Average",
        "region": "il-central-1",
        "title": "Lambda Performance"
      }
    }
  ]
}
```

### Database Dashboard
```json
{
  "widgets": [
    {
      "type": "metric",
      "properties": {
        "metrics": [
          ["AWS/RDS", "CPUUtilization", "DBClusterIdentifier", "aurora-cluster"],
          ["AWS/RDS", "DatabaseConnections", "DBClusterIdentifier", "aurora-cluster"],
          ["AWS/RDS", "ReadLatency", "DBClusterIdentifier", "aurora-cluster"],
          ["AWS/RDS", "WriteLatency", "DBClusterIdentifier", "aurora-cluster"]
        ],
        "period": 300,
        "stat": "Average",
        "region": "il-central-1",
        "title": "Database Performance"
      }
    }
  ]
}
```

## Structured Logging

### Log Format
```python
import json
import logging
from aws_lambda_powertools import Logger

logger = Logger(service="testmeout-api")

@logger.inject_lambda_context
def handler(event, context):
    logger.info("Processing request", extra={
        "user_id": event.get("user_id"),
        "request_id": context.aws_request_id,
        "function_name": context.function_name,
        "remaining_time": context.get_remaining_time_in_millis()
    })
    
    try:
        # Process request
        result = process_request(event)
        
        logger.info("Request completed successfully", extra={
            "processing_time_ms": processing_time,
            "result_size": len(str(result))
        })
        
        return result
        
    except Exception as e:
        logger.error("Request failed", extra={
            "error_type": type(e).__name__,
            "error_message": str(e),
            "stack_trace": traceback.format_exc()
        })
        raise
```

### Log Aggregation Queries
```sql
-- CloudWatch Logs Insights queries

-- Find errors in last hour
fields @timestamp, @message, error_type, error_message
| filter @timestamp > @now - 1h
| filter level = "ERROR"
| sort @timestamp desc

-- Track API response times
fields @timestamp, @duration, function_name
| filter @type = "REPORT"
| stats avg(@duration), max(@duration), min(@duration) by function_name

-- Monitor user activity
fields @timestamp, user_id, action
| filter action = "chat_message_sent"
| stats count() by user_id
| sort count desc
```

## Distributed Tracing with X-Ray

### Lambda Function Tracing
```python
from aws_lambda_powertools import Tracer

tracer = Tracer(service="testmeout-api")

@tracer.capture_lambda_handler
def handler(event, context):
    return process_request(event)

@tracer.capture_method
def process_request(event):
    # Add custom annotations
    tracer.put_annotation("user_id", event.get("user_id"))
    tracer.put_annotation("request_type", event.get("type"))
    
    # Add metadata
    tracer.put_metadata("request_details", {
        "path": event.get("path"),
        "method": event.get("httpMethod"),
        "headers": event.get("headers", {})
    })
    
    # Trace external calls
    with tracer.capture_subsegment("database_query"):
        result = query_database(event)
    
    with tracer.capture_subsegment("bedrock_call"):
        ai_response = call_bedrock(event)
    
    return combine_results(result, ai_response)
```

### Service Map
X-Ray automatically creates a service map showing:
- API Gateway → Lambda → RDS
- Lambda → Bedrock
- Lambda → S3
- Lambda → SQS

## Alerting Strategy

### Critical Alarms (P1)
```python
# High error rate
error_alarm = cloudwatch.Alarm(
    self, "HighErrorRate",
    metric=api.metric("5XXError"),
    threshold=10,
    evaluation_periods=2,
    datapoints_to_alarm=2,
    alarm_description="High API error rate"
)

# Database down
db_alarm = cloudwatch.Alarm(
    self, "DatabaseDown",
    metric=cluster.metric_cpu_utilization(),
    threshold=0,
    comparison_operator=cloudwatch.ComparisonOperator.LESS_THAN_THRESHOLD,
    evaluation_periods=3,
    alarm_description="Database cluster is down"
)
```

### Warning Alarms (P2)
```python
# High latency
latency_alarm = cloudwatch.Alarm(
    self, "HighLatency", 
    metric=api.metric("Latency"),
    threshold=5000,  # 5 seconds
    statistic="Average",
    evaluation_periods=3
)

# Lambda throttling
throttle_alarm = cloudwatch.Alarm(
    self, "LambdaThrottles",
    metric=function.metric_throttles(),
    threshold=5,
    evaluation_periods=2
)
```

### Info Alarms (P3)
```python
# High memory usage
memory_alarm = cloudwatch.Alarm(
    self, "HighMemoryUsage",
    metric=cluster.metric_database_connections(),
    threshold=80,  # 80% of max connections
    evaluation_periods=5
)
```

## Performance Monitoring

### Response Time Tracking
```python
import time
from contextlib import contextmanager

@contextmanager
def track_performance(operation_name: str):
    start_time = time.time()
    try:
        yield
    finally:
        duration = (time.time() - start_time) * 1000
        metrics.add_metric(
            name=f"{operation_name}Duration",
            unit=MetricUnit.Milliseconds,
            value=duration
        )

# Usage
def process_document(document_id: str):
    with track_performance("DocumentProcessing"):
        # Processing logic
        pass
```

### Cold Start Monitoring
```python
import os

# Track cold starts
is_cold_start = not hasattr(process_document, 'initialized')
if is_cold_start:
    metrics.add_metric(name="ColdStart", unit=MetricUnit.Count, value=1)
    process_document.initialized = True
```

## Cost Monitoring

### Cost Allocation Tags
```python
# Apply consistent tags to all resources
common_tags = {
    "Environment": env_name,
    "Project": "TestMeOut",
    "CostCenter": "Engineering",
    "Owner": "platform-team"
}

# Apply to resources
bucket = s3.Bucket(
    self, "DocumentBucket",
    tags=common_tags
)
```

### Budget Alerts
```python
budget = budgets.CfnBudget(
    self, "MonthlyBudget",
    budget={
        "budgetName": f"TestMeOut-{env_name}-Monthly",
        "budgetLimit": {
            "amount": "1000",  # $1000 USD
            "unit": "USD"
        },
        "timeUnit": "MONTHLY",
        "budgetType": "COST"
    },
    notifications_with_subscribers=[
        {
            "notification": {
                "notificationType": "ACTUAL",
                "comparisonOperator": "GREATER_THAN",
                "threshold": 80  # Alert at 80% of budget
            },
            "subscribers": [
                {
                    "subscriptionType": "EMAIL",
                    "address": "platform-team@company.com"
                }
            ]
        }
    ]
)
```

## Health Checks

### Application Health Check
```python
def health_check():
    """Comprehensive health check."""
    health_status = {
        "status": "healthy",
        "timestamp": datetime.utcnow().isoformat(),
        "checks": {}
    }
    
    # Database check
    try:
        with db_pool.get_connection() as conn:
            with conn.cursor() as cursor:
                cursor.execute("SELECT 1")
        health_status["checks"]["database"] = "healthy"
    except Exception as e:
        health_status["checks"]["database"] = "unhealthy"
        health_status["status"] = "degraded"
    
    # S3 check
    try:
        s3_client.head_bucket(Bucket=DOCUMENT_BUCKET)
        health_status["checks"]["s3"] = "healthy"
    except Exception:
        health_status["checks"]["s3"] = "unhealthy"
        health_status["status"] = "degraded"
    
    # Bedrock check
    try:
        bedrock_client.list_foundation_models()
        health_status["checks"]["bedrock"] = "healthy"
    except Exception:
        health_status["checks"]["bedrock"] = "unhealthy"
        health_status["status"] = "degraded"
    
    return health_status
```

### External Health Check
```python
# External monitoring service
import requests

def external_health_check():
    """Health check from external service."""
    endpoints = [
        "https://api.testmeout.com/api/health",
        "https://app.testmeout.com/health"
    ]
    
    for endpoint in endpoints:
        try:
            response = requests.get(endpoint, timeout=10)
            if response.status_code != 200:
                send_alert(f"Health check failed for {endpoint}")
        except Exception as e:
            send_alert(f"Health check error for {endpoint}: {e}")
```

## Incident Response

### Automated Response
```python
# Lambda function for automated incident response
def incident_response_handler(event, context):
    """Handle CloudWatch alarm events."""
    alarm_data = json.loads(event['Records'][0]['Sns']['Message'])
    alarm_name = alarm_data['AlarmName']
    state = alarm_data['NewStateValue']
    
    if state == "ALARM":
        if "HighErrorRate" in alarm_name:
            # Scale up Lambda concurrency
            lambda_client.put_provisioned_concurrency_config(
                FunctionName="MainApiFunction",
                ProvisionedConcurrencyConfig={
                    'ProvisionedConcurrencyConfig': 10
                }
            )
        
        elif "DatabaseDown" in alarm_name:
            # Trigger database failover
            rds_client.failover_db_cluster(
                DBClusterIdentifier="aurora-cluster"
            )
        
        # Send alert to team
        send_slack_alert(alarm_data)
```

### Manual Runbooks
1. **High Error Rate Response**
   - Check CloudWatch Logs for error details
   - Review recent deployments
   - Scale Lambda concurrency if needed
   - Consider rollback if deployment-related

2. **Database Issues**
   - Check database metrics
   - Review slow query log
   - Consider read replica promotion
   - Scale instance if CPU/memory constrained

3. **Performance Degradation**
   - Analyze X-Ray traces
   - Check for cold starts
   - Review database query performance
   - Monitor external service dependencies

## Monitoring Best Practices

### Metric Collection
1. Use structured logging
2. Include correlation IDs
3. Track business metrics
4. Monitor error rates and latency
5. Set up proper alerting thresholds

### Dashboard Design
1. Start with high-level overview
2. Drill down to specific components
3. Include SLA/SLO metrics
4. Use consistent time ranges
5. Add annotations for deployments

### Alert Management
1. Minimize false positives
2. Use appropriate thresholds
3. Include runbook links
4. Set up escalation policies
5. Regular review and tuning