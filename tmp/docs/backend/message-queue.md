# Message Queue Documentation

## Overview

Amazon SQS provides reliable, scalable message queuing for asynchronous document processing and other background tasks. The system uses both standard and FIFO queues with dead letter queue (DLQ) support.

## Queue Architecture

### Document Processing Queue
- **Type**: Standard Queue
- **Purpose**: Asynchronous document processing
- **Visibility Timeout**: 15 minutes
- **Message Retention**: 14 days
- **Dead Letter Queue**: Yes (3 max receives)

### Notification Queue
- **Type**: FIFO Queue
- **Purpose**: Ordered notification delivery
- **Deduplication**: Content-based
- **Message Group**: By user ID

## Message Flow

### Document Upload Flow
1. User uploads document to S3
2. S3 triggers Lambda function
3. Lambda sends message to SQS
4. Document processor consumes message
5. Processing results stored in database

## Queue Configuration

### Standard Queue Setup
```python
processing_queue = sqs.Queue(
    self, "ProcessingQueue",
    visibility_timeout=Duration.minutes(15),
    message_retention_period=Duration.days(14),
    dead_letter_queue=sqs.DeadLetterQueue(
        max_receive_count=3,
        queue=dlq
    )
)
```

## Message Formats

### Document Processing Message
```json
{
  "messageId": "uuid",
  "documentId": "doc_uuid",
  "userId": "user_uuid",
  "action": "process",
  "s3Bucket": "documents",
  "s3Key": "path/to/document.pdf",
  "metadata": {
    "mimeType": "application/pdf",
    "size": 1048576
  }
}
```

## Error Handling

### Retry Logic
- Exponential backoff
- Maximum retry attempts
- DLQ for failed messages

### Dead Letter Queue Processing
- Manual review of failed messages
- Reprocessing capabilities
- Alerting on DLQ messages

## Monitoring

### CloudWatch Metrics
- Queue depth
- Message age
- DLQ message count
- Processing rate

### Alarms
- High queue depth
- Old messages
- DLQ threshold
- Processing failures