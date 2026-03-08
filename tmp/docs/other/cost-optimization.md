# Cost Optimization Guide

## Overview

This guide provides strategies and best practices for optimizing AWS costs while maintaining performance and reliability for the Legal Information System.

## Cost Analysis

### Current Cost Structure
- **Lambda Functions**: 40% of total cost
- **Aurora PostgreSQL**: 30% of total cost
- **API Gateway**: 15% of total cost
- **S3 Storage**: 10% of total cost
- **Other Services**: 5% of total cost

## Lambda Optimization

### Right-Sizing Memory
```python
# Test different memory configurations
memory_configs = [512, 1024, 1536, 2048, 3008]

for memory in memory_configs:
    # Deploy and measure
    duration = measure_execution_time(memory)
    cost = calculate_cost(memory, duration)
    print(f"Memory: {memory}MB, Duration: {duration}ms, Cost: ${cost}")
```

### ARM Architecture (Graviton2)
```python
# Use ARM for 20% cost savings
lambda_function = lambda_.Function(
    self, "OptimizedFunction",
    runtime=lambda_.Runtime.PYTHON_3_12,
    architecture=lambda_.Architecture.ARM_64,  # 20% cheaper
    memory_size=1024
)
```

### Provisioned Concurrency Optimization
```python
# Only use provisioned concurrency for critical functions
if env_name == "prod" and function_name == "MainApiFunction":
    function.add_provisioned_concurrent_executions(
        "ProvisionedConcurrency",
        provisioned_executions=5  # Minimum needed
    )
```

## Database Cost Optimization

### Instance Right-Sizing
```python
# Environment-specific instance types
instance_types = {
    "dev": "t4g.medium",      # $0.064/hour
    "staging": "t4g.large",   # $0.128/hour  
    "prod": "r6g.xlarge"      # $0.302/hour
}

cluster = rds.DatabaseCluster(
    self, "AuroraCluster",
    instance_props=rds.InstanceProps(
        instance_type=ec2.InstanceType(instance_types[env_name])
    )
)
```

### Aurora Serverless v2
```python
# For variable workloads
cluster = rds.DatabaseCluster(
    self, "ServerlessCluster",
    engine=rds.DatabaseClusterEngine.aurora_postgres(
        version=rds.AuroraPostgresEngineVersion.VER_15_4
    ),
    serverless_v2_min_capacity=0.5,  # Scale to zero when idle
    serverless_v2_max_capacity=4.0   # Scale up as needed
)
```

### Backup Optimization
```python
# Optimize backup retention by environment
backup_retention = {
    "dev": 1,      # 1 day
    "staging": 7,  # 1 week
    "prod": 30     # 1 month
}

cluster = rds.DatabaseCluster(
    self, "AuroraCluster",
    backup=rds.BackupProps(
        retention=Duration.days(backup_retention[env_name])
    )
)
```

## Storage Cost Optimization

### S3 Lifecycle Policies
```python
bucket = s3.Bucket(
    self, "DocumentBucket",
    lifecycle_rules=[
        s3.LifecycleRule(
            id="optimize-storage-costs",
            enabled=True,
            transitions=[
                s3.Transition(
                    storage_class=s3.StorageClass.INFREQUENT_ACCESS,
                    transition_after=Duration.days(30)
                ),
                s3.Transition(
                    storage_class=s3.StorageClass.GLACIER,
                    transition_after=Duration.days(90)
                ),
                s3.Transition(
                    storage_class=s3.StorageClass.DEEP_ARCHIVE,
                    transition_after=Duration.days(365)
                )
            ],
            expiration=Duration.days(2555)  # 7 years retention
        )
    ]
)
```

### Intelligent Tiering
```python
bucket = s3.Bucket(
    self, "DocumentBucket",
    intelligent_tiering_configurations=[
        s3.IntelligentTieringConfiguration(
            id="entire-bucket",
            status=s3.IntelligentTieringStatus.ENABLED
        )
    ]
)
```

## API Gateway Cost Optimization

### HTTP API vs REST API
```python
# HTTP API is 70% cheaper than REST API
http_api = apigatewayv2.HttpApi(
    self, "HttpApi",  # Use HTTP API instead of REST API
    cors_configuration={
        "allow_origins": ["*"],
        "allow_methods": ["*"],
        "allow_headers": ["*"]
    }
)
```

### Caching Strategy
```python
# Enable caching only for production
if env_name == "prod":
    api.add_routes(
        path="/api/{proxy+}",
        methods=[apigatewayv2.HttpMethod.GET],
        integration=integration,
        cache_key_parameters=["proxy"],
        cache_ttl=Duration.minutes(5)
    )
```

## CloudWatch Cost Optimization

### Log Retention
```python
# Environment-specific log retention
log_retention = {
    "dev": logs.RetentionDays.ONE_WEEK,
    "staging": logs.RetentionDays.ONE_MONTH,
    "prod": logs.RetentionDays.THREE_MONTHS
}

log_group = logs.LogGroup(
    self, "LogGroup",
    retention=log_retention[env_name]
)
```

### Metric Filters
```python
# Only create detailed metrics for production
if env_name == "prod":
    log_group.add_metric_filter(
        "ErrorMetric",
        metric_name="ErrorCount",
        metric_namespace="TestMeOut/API",
        filter_pattern=logs.FilterPattern.literal("[ERROR]")
    )
```

## Monitoring Cost Optimization

### Selective X-Ray Tracing
```python
# Reduce X-Ray costs with sampling
tracer = Tracer(
    service="testmeout-api",
    sampling_rate=0.1 if env_name != "prod" else 0.01  # 10% dev, 1% prod
)
```

### Custom Metrics Optimization
```python
# Batch custom metrics to reduce API calls
metrics_buffer = []

def add_metric_to_buffer(name: str, value: float):
    metrics_buffer.append({
        "MetricName": name,
        "Value": value,
        "Unit": "Count"
    })
    
    # Flush when buffer is full
    if len(metrics_buffer) >= 20:
        flush_metrics_buffer()

def flush_metrics_buffer():
    if metrics_buffer:
        cloudwatch.put_metric_data(
            Namespace="TestMeOut/API",
            MetricData=metrics_buffer
        )
        metrics_buffer.clear()
```

## Reserved Instances and Savings Plans

### RDS Reserved Instances
```bash
# Purchase 1-year reserved instances for production
aws rds purchase-reserved-db-instances-offering \
    --reserved-db-instances-offering-id xxx \
    --reserved-db-instance-id prod-aurora-ri \
    --db-instance-count 2
```

### Compute Savings Plans
```bash
# Purchase compute savings plan for Lambda
aws savingsplans purchase-savings-plan \
    --savings-plan-offering-id xxx \
    --commitment 100 \
    --upfront-payment-amount 0 \
    --purchase-time $(date -u +%Y-%m-%dT%H:%M:%SZ)
```

## Environment-Specific Optimizations

### Development Environment
```python
dev_optimizations = {
    # Minimal resources
    "lambda_memory": 512,
    "db_instance": "t4g.small",
    "backup_retention": 1,
    "log_retention": 7,
    
    # Auto-shutdown
    "auto_shutdown": True,
    "shutdown_schedule": "0 20 * * MON-FRI",  # Shutdown at 8 PM weekdays
    "startup_schedule": "0 8 * * MON-FRI"     # Start at 8 AM weekdays
}
```

### Production Environment
```python
prod_optimizations = {
    # Right-sized resources
    "lambda_memory": 1024,
    "db_instance": "r6g.large",
    "reserved_instances": True,
    
    # Cost monitoring
    "budget_alerts": True,
    "cost_anomaly_detection": True
}
```

## Cost Monitoring

### Budget Alerts
```python
budget = budgets.CfnBudget(
    self, "CostBudget",
    budget={
        "budgetName": f"TestMeOut-{env_name}",
        "budgetLimit": {
            "amount": str(budget_limits[env_name]),
            "unit": "USD"
        },
        "timeUnit": "MONTHLY",
        "budgetType": "COST"
    },
    notifications_with_subscribers=[
        {
            "notification": {
                "notificationType": "FORECASTED",
                "comparisonOperator": "GREATER_THAN",
                "threshold": 80
            },
            "subscribers": [{
                "subscriptionType": "EMAIL",
                "address": "platform-team@company.com"
            }]
        }
    ]
)
```

### Cost Anomaly Detection
```python
anomaly_detector = ce.CfnAnomalyDetector(
    self, "CostAnomalyDetector",
    monitor={
        "monitorName": f"TestMeOut-{env_name}-Anomaly",
        "monitorType": "DIMENSIONAL",
        "monitorSpecification": json.dumps({
            "Dimension": "SERVICE",
            "MatchOptions": ["EQUALS"],
            "Values": ["Amazon Elastic Compute Cloud - Compute"]
        })
    }
)
```

## Automated Cost Optimization

### Lambda Auto-Scaling
```python
def lambda_cost_optimizer():
    """Automatically optimize Lambda memory based on usage."""
    cloudwatch = boto3.client('cloudwatch')
    lambda_client = boto3.client('lambda')
    
    # Get Lambda metrics
    metrics = cloudwatch.get_metric_statistics(
        Namespace='AWS/Lambda',
        MetricName='Duration',
        Dimensions=[{'Name': 'FunctionName', 'Value': function_name}],
        StartTime=datetime.utcnow() - timedelta(days=7),
        EndTime=datetime.utcnow(),
        Period=3600,
        Statistics=['Average', 'Maximum']
    )
    
    # Analyze and optimize
    avg_duration = sum(m['Average'] for m in metrics['Datapoints']) / len(metrics['Datapoints'])
    
    if avg_duration < 1000:  # Less than 1 second
        # Consider reducing memory
        current_config = lambda_client.get_function_configuration(FunctionName=function_name)
        if current_config['MemorySize'] > 512:
            lambda_client.update_function_configuration(
                FunctionName=function_name,
                MemorySize=max(512, current_config['MemorySize'] - 256)
            )
```

### Database Auto-Scaling
```python
# Aurora Serverless v2 auto-scaling
cluster = rds.DatabaseCluster(
    self, "AutoScalingCluster",
    serverless_v2_min_capacity=0.5,
    serverless_v2_max_capacity=16.0,
    enable_performance_insights=True
)
```

## Cost Reporting

### Weekly Cost Report
```python
def generate_cost_report():
    """Generate weekly cost breakdown."""
    ce_client = boto3.client('ce')
    
    response = ce_client.get_cost_and_usage(
        TimePeriod={
            'Start': (datetime.now() - timedelta(days=7)).strftime('%Y-%m-%d'),
            'End': datetime.now().strftime('%Y-%m-%d')
        },
        Granularity='DAILY',
        Metrics=['BlendedCost'],
        GroupBy=[
            {'Type': 'DIMENSION', 'Key': 'SERVICE'},
            {'Type': 'TAG', 'Key': 'Environment'}
        ]
    )
    
    # Process and send report
    cost_breakdown = process_cost_data(response)
    send_cost_report(cost_breakdown)
```

### Cost Optimization Recommendations
```python
def get_cost_recommendations():
    """Get AWS cost optimization recommendations."""
    ce_client = boto3.client('ce')
    
    # Get rightsizing recommendations
    rightsizing = ce_client.get_rightsizing_recommendation(
        Service='AmazonEC2',
        Configuration={
            'BenefitsConsidered': True,
            'RecommendationTarget': 'SAME_INSTANCE_FAMILY'
        }
    )
    
    # Get reserved instance recommendations
    ri_recommendations = ce_client.get_reservation_purchase_recommendation(
        Service='AmazonRDS',
        AccountScope='PAYER'
    )
    
    return {
        'rightsizing': rightsizing,
        'reserved_instances': ri_recommendations
    }
```

## Best Practices

### Cost-Conscious Development
1. **Use appropriate instance sizes for environments**
2. **Implement auto-shutdown for development resources**
3. **Monitor and optimize Lambda memory allocation**
4. **Use lifecycle policies for S3 storage**
5. **Implement proper resource tagging**

### Regular Reviews
1. **Weekly cost reports**
2. **Monthly cost optimization reviews**
3. **Quarterly reserved instance analysis**
4. **Annual architecture cost review**

### Automation
1. **Automated resource scheduling**
2. **Cost anomaly detection**
3. **Automated rightsizing recommendations**
4. **Budget alerts and notifications**