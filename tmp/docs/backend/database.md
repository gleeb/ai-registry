# Database Design Documentation

## Overview

The Legal Information System uses Aurora PostgreSQL 15.4 with the pgvector extension for storing application data and enabling semantic search capabilities. The database is designed for high availability, scalability, and efficient vector similarity searches.

## Database Architecture

### Aurora PostgreSQL Configuration
- **Engine**: Aurora PostgreSQL 15.4
- **Instance Type**: t4g.medium (dev), r6g.large (prod)
- **Multi-AZ**: Yes (production)
- **Read Replicas**: 1 (auto-scaling based on load)
- **Backup**: Automated daily backups with 7-day retention
- **Encryption**: AES-256 encryption at rest

### pgvector Extension Setup

The database uses pgvector for vector similarity searches. Since Aurora PostgreSQL has restrictions on direct extension loading, pgvector is installed using Trusted Language Extensions (pg_tle).

#### Installation Process

1. **Connect to Database**:
   ```bash
   # Get database credentials
   aws secretsmanager get-secret-value --secret-id "lawinfo/sandbox/database/credentials" --query SecretString --output text
   
   # Connect to database
   psql -h <cluster-endpoint> -U <username> -d lawinfo
   ```

2. **Install pgvector via pg_tle**:
   ```sql
   -- Enable pg_tle extension
   CREATE EXTENSION IF NOT EXISTS pg_tle;
   
   -- Install pgvector using pg_tle
   SELECT pgtle.install_extension(
       'vector',
       '1.0.0',
       'pgvector extension for vector operations'
   );
   
   -- Create the vector extension
   CREATE EXTENSION vector;
   ```

3. **Verify Installation**:
   ```sql
   -- Check if vector extension is available
   SELECT * FROM pg_extension WHERE extname = 'vector';
   
   -- Test vector operations
   SELECT '[1,2,3]'::vector;
   ```

#### Migration Automation

For production deployments, create a Liquibase migration:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<databaseChangeLog
    xmlns="http://www.liquibase.org/xml/ns/dbchangelog"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.liquibase.org/xml/ns/dbchangelog
                        http://www.liquibase.org/xml/ns/dbchangelog/dbchangelog-4.3.xsd">

    <changeSet id="install-pgvector" author="system">
        <sql>
            -- Enable pg_tle extension
            CREATE EXTENSION IF NOT EXISTS pg_tle;
            
            -- Install pgvector using pg_tle
            SELECT pgtle.install_extension(
                'vector',
                '1.0.0',
                'pgvector extension for vector operations'
            );
            
            -- Create the vector extension
            CREATE EXTENSION vector;
        </sql>
    </changeSet>

</databaseChangeLog>
```

#### Troubleshooting

**Common Issues**:
1. **pg_tle not available**: Ensure parameter group has `shared_preload_libraries = pg_tle`
2. **Permission denied**: Ensure database user has sufficient privileges
3. **Extension already exists**: Use `CREATE EXTENSION IF NOT EXISTS vector;`

**Verification Commands**:
```sql
-- Check pg_tle is enabled
SHOW shared_preload_libraries;

-- List available extensions
SELECT * FROM pg_extension;

-- Test vector functionality
SELECT '[1,2,3]'::vector + '[4,5,6]'::vector;
```

### Connection Management
```python
# Connection pooling configuration
DATABASE_CONFIG = {
    'host': os.environ['DB_HOST'],
    'port': 5432,
    'database': 'lawinfo',
    'user': os.environ['DB_USER'],
    'password': get_secret('db-password'),
    'min_conn': 2,
    'max_conn': 10,
    'connect_timeout': 10,
    'command_timeout': 60
}
```

## Database Schema

### Core Tables

#### users
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cognito_id VARCHAR(255) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255),
    role VARCHAR(50) DEFAULT 'user',
    preferences JSONB DEFAULT '{}',
    status VARCHAR(50) DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_login_at TIMESTAMP WITH TIME ZONE,
    metadata JSONB DEFAULT '{}'
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_cognito_id ON users(cognito_id);
CREATE INDEX idx_users_status ON users(status);
```

#### documents
```sql
CREATE TABLE documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(500) NOT NULL,
    original_name VARCHAR(500),
    mime_type VARCHAR(100),
    size_bytes BIGINT,
    s3_key VARCHAR(1000) NOT NULL,
    s3_bucket VARCHAR(255) NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    category VARCHAR(100),
    tags TEXT[],
    extracted_text TEXT,
    summary TEXT,
    metadata JSONB DEFAULT '{}',
    processing_started_at TIMESTAMP WITH TIME ZONE,
    processing_completed_at TIMESTAMP WITH TIME ZONE,
    processing_error TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_documents_user_id ON documents(user_id);
CREATE INDEX idx_documents_status ON documents(status);
CREATE INDEX idx_documents_category ON documents(category);
CREATE INDEX idx_documents_created_at ON documents(created_at DESC);
CREATE INDEX idx_documents_tags ON documents USING GIN(tags);
```

#### conversations
```sql
CREATE TABLE conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(500),
    model VARCHAR(100),
    status VARCHAR(50) DEFAULT 'active',
    message_count INTEGER DEFAULT 0,
    total_tokens INTEGER DEFAULT 0,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_message_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_conversations_user_id ON conversations(user_id);
CREATE INDEX idx_conversations_updated_at ON conversations(updated_at DESC);
CREATE INDEX idx_conversations_status ON conversations(status);
```

#### messages
```sql
CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID REFERENCES conversations(id) ON DELETE CASCADE,
    role VARCHAR(50) NOT NULL, -- 'user', 'assistant', 'system'
    content TEXT NOT NULL,
    model VARCHAR(100),
    thought_process TEXT,
    citations JSONB DEFAULT '[]',
    tokens_used INTEGER,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_messages_conversation_id ON messages(conversation_id);
CREATE INDEX idx_messages_created_at ON messages(created_at);
CREATE INDEX idx_messages_role ON messages(role);
```

### Vector Search Tables

#### document_embeddings
```sql
-- Enable pgvector extension
CREATE EXTENSION IF NOT EXISTS vector;

CREATE TABLE document_embeddings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    document_id UUID REFERENCES documents(id) ON DELETE CASCADE,
    chunk_index INTEGER NOT NULL,
    chunk_text TEXT NOT NULL,
    embedding vector(1536), -- OpenAI embeddings dimension
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(document_id, chunk_index)
);

-- Create indexes for similarity search
CREATE INDEX idx_embeddings_document_id ON document_embeddings(document_id);
CREATE INDEX idx_embeddings_vector_cosine ON document_embeddings 
    USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);
CREATE INDEX idx_embeddings_vector_l2 ON document_embeddings 
    USING ivfflat (embedding vector_l2_ops) WITH (lists = 100);
```

#### message_embeddings
```sql
CREATE TABLE message_embeddings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    message_id UUID REFERENCES messages(id) ON DELETE CASCADE,
    embedding vector(1536),
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_message_embeddings_message_id ON message_embeddings(message_id);
CREATE INDEX idx_message_embeddings_vector ON message_embeddings 
    USING ivfflat (embedding vector_cosine_ops) WITH (lists = 50);
```

### Audit Tables

#### audit_log
```sql
CREATE TABLE audit_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(100),
    entity_id UUID,
    old_values JSONB,
    new_values JSONB,
    ip_address INET,
    user_agent TEXT,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_audit_log_user_id ON audit_log(user_id);
CREATE INDEX idx_audit_log_entity ON audit_log(entity_type, entity_id);
CREATE INDEX idx_audit_log_created_at ON audit_log(created_at DESC);
CREATE INDEX idx_audit_log_action ON audit_log(action);
```

## Vector Search Implementation

### Similarity Search Query
```sql
-- Semantic search for documents
WITH semantic_matches AS (
    SELECT 
        de.document_id,
        de.chunk_index,
        de.chunk_text,
        1 - (de.embedding <=> $1::vector) AS similarity
    FROM document_embeddings de
    WHERE 1 - (de.embedding <=> $1::vector) > $2 -- similarity threshold
    ORDER BY de.embedding <=> $1::vector
    LIMIT $3
)
SELECT 
    d.id,
    d.name,
    d.category,
    sm.chunk_text,
    sm.similarity,
    sm.chunk_index
FROM semantic_matches sm
JOIN documents d ON d.id = sm.document_id
WHERE d.status = 'processed'
ORDER BY sm.similarity DESC;
```

### Hybrid Search (Keyword + Semantic)
```sql
-- Combine full-text search with vector similarity
WITH keyword_matches AS (
    SELECT 
        id,
        name,
        ts_rank(to_tsvector('english', extracted_text), 
                plainto_tsquery('english', $1)) AS keyword_score
    FROM documents
    WHERE to_tsvector('english', extracted_text) @@ 
          plainto_tsquery('english', $1)
),
semantic_matches AS (
    SELECT 
        document_id,
        MAX(1 - (embedding <=> $2::vector)) AS semantic_score
    FROM document_embeddings
    WHERE 1 - (embedding <=> $2::vector) > 0.5
    GROUP BY document_id
)
SELECT 
    d.id,
    d.name,
    d.category,
    COALESCE(km.keyword_score, 0) * 0.3 + 
    COALESCE(sm.semantic_score, 0) * 0.7 AS combined_score
FROM documents d
LEFT JOIN keyword_matches km ON km.id = d.id
LEFT JOIN semantic_matches sm ON sm.document_id = d.id
WHERE km.id IS NOT NULL OR sm.document_id IS NOT NULL
ORDER BY combined_score DESC
LIMIT $3;
```

## Database Access Patterns

### Connection Pooling
```python
import psycopg2
from psycopg2 import pool
from contextlib import contextmanager

class DatabasePool:
    def __init__(self, **kwargs):
        self.pool = psycopg2.pool.ThreadedConnectionPool(
            minconn=kwargs.get('min_conn', 2),
            maxconn=kwargs.get('max_conn', 10),
            host=kwargs['host'],
            port=kwargs['port'],
            database=kwargs['database'],
            user=kwargs['user'],
            password=kwargs['password']
        )
    
    @contextmanager
    def get_connection(self):
        conn = self.pool.getconn()
        try:
            yield conn
            conn.commit()
        except Exception:
            conn.rollback()
            raise
        finally:
            self.pool.putconn(conn)

# Global pool instance
db_pool = DatabasePool(**DATABASE_CONFIG)
```

### Query Patterns
```python
class DocumentRepository:
    def __init__(self, db_pool):
        self.db_pool = db_pool
    
    def create_document(self, user_id: str, document_data: dict) -> str:
        """Create a new document record."""
        query = """
            INSERT INTO documents (
                user_id, name, mime_type, size_bytes, 
                s3_key, s3_bucket, category, tags
            ) VALUES (
                %s, %s, %s, %s, %s, %s, %s, %s
            ) RETURNING id
        """
        
        with self.db_pool.get_connection() as conn:
            with conn.cursor() as cursor:
                cursor.execute(query, (
                    user_id,
                    document_data['name'],
                    document_data['mime_type'],
                    document_data['size_bytes'],
                    document_data['s3_key'],
                    document_data['s3_bucket'],
                    document_data.get('category'),
                    document_data.get('tags', [])
                ))
                return cursor.fetchone()[0]
    
    def search_documents(self, query_embedding: list, threshold: float = 0.7) -> list:
        """Semantic search for documents."""
        query = """
            SELECT 
                d.id,
                d.name,
                de.chunk_text,
                1 - (de.embedding <=> %s::vector) AS similarity
            FROM document_embeddings de
            JOIN documents d ON d.id = de.document_id
            WHERE 1 - (de.embedding <=> %s::vector) > %s
            ORDER BY de.embedding <=> %s::vector
            LIMIT 10
        """
        
        with self.db_pool.get_connection() as conn:
            with conn.cursor() as cursor:
                embedding_str = f'[{",".join(map(str, query_embedding))}]'
                cursor.execute(query, (
                    embedding_str, embedding_str, 
                    threshold, embedding_str
                ))
                return cursor.fetchall()
```

## Database Migrations

### Liquibase Configuration
```xml
<!-- changelog.xml -->
<databaseChangeLog>
    <changeSet id="1" author="system">
        <createTable tableName="users">
            <column name="id" type="UUID" defaultValueComputed="gen_random_uuid()">
                <constraints primaryKey="true"/>
            </column>
            <column name="email" type="VARCHAR(255)">
                <constraints nullable="false" unique="true"/>
            </column>
            <!-- Additional columns -->
        </createTable>
    </changeSet>
    
    <changeSet id="2" author="system">
        <sql>CREATE EXTENSION IF NOT EXISTS vector;</sql>
    </changeSet>
</databaseChangeLog>
```

### Migration Lambda
```python
def run_migrations(event, context):
    """Execute database migrations."""
    import subprocess
    
    # Get database credentials
    db_config = get_database_config()
    
    # Run Liquibase
    cmd = [
        'java', '-jar', '/opt/liquibase.jar',
        '--url', f"jdbc:postgresql://{db_config['host']}:{db_config['port']}/{db_config['database']}",
        '--username', db_config['user'],
        '--password', db_config['password'],
        '--changeLogFile', 'changelog.xml',
        'update'
    ]
    
    result = subprocess.run(cmd, capture_output=True, text=True)
    
    if result.returncode != 0:
        raise Exception(f"Migration failed: {result.stderr}")
    
    return {
        'statusCode': 200,
        'body': json.dumps({'message': 'Migrations completed successfully'})
    }
```

## Performance Optimization

### Indexing Strategy
1. **B-tree indexes** for equality and range queries
2. **GIN indexes** for JSONB and array columns
3. **IVFFlat indexes** for vector similarity search
4. **Partial indexes** for filtered queries

### Query Optimization
```sql
-- Use EXPLAIN ANALYZE to optimize queries
EXPLAIN (ANALYZE, BUFFERS) 
SELECT * FROM documents 
WHERE user_id = 'uuid' AND status = 'processed'
ORDER BY created_at DESC 
LIMIT 10;

-- Create composite indexes for common queries
CREATE INDEX idx_documents_user_status_created 
ON documents(user_id, status, created_at DESC);
```

### Connection Pool Tuning
```python
# Optimal pool settings based on Lambda concurrency
POOL_CONFIG = {
    'min_conn': 2,      # Minimum connections
    'max_conn': 10,     # Maximum connections
    'max_idle': 300,    # Max idle time (seconds)
    'max_lifetime': 3600 # Max connection lifetime
}
```

## Backup and Recovery

### Backup Strategy
- **Automated Backups**: Daily at 3 AM UTC
- **Retention Period**: 7 days (dev), 30 days (prod)
- **Point-in-Time Recovery**: Enabled
- **Cross-Region Backups**: For production

### Restore Procedures
```bash
# Restore to point in time
aws rds restore-db-cluster-to-point-in-time \
    --source-db-cluster-identifier prod-cluster \
    --target-db-cluster-identifier restored-cluster \
    --restore-to-time 2024-01-01T12:00:00.000Z

# Restore from snapshot
aws rds restore-db-cluster-from-snapshot \
    --db-cluster-identifier restored-cluster \
    --snapshot-identifier snapshot-id
```

## Monitoring

### Key Metrics
- **Connection count**: Monitor pool usage
- **Query latency**: P50, P95, P99
- **Deadlocks**: Alert on occurrences
- **Replication lag**: For read replicas
- **Storage usage**: Alert at 80% capacity

### CloudWatch Alarms
```python
# Create alarm for high connection count
alarm = cloudwatch.Alarm(
    self, "HighDatabaseConnections",
    metric=Metric(
        namespace="AWS/RDS",
        metric_name="DatabaseConnections",
        dimensions={"DBClusterIdentifier": cluster.cluster_identifier}
    ),
    threshold=80,
    evaluation_periods=2
)
```

## Security

### Encryption
- **At Rest**: AES-256 encryption
- **In Transit**: SSL/TLS required
- **Key Management**: AWS KMS

### Access Control
```sql
-- Create read-only user for analytics
CREATE USER analytics_user WITH PASSWORD 'secure_password';
GRANT CONNECT ON DATABASE lawinfo TO analytics_user;
GRANT USAGE ON SCHEMA public TO analytics_user;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO analytics_user;

-- Create application user with limited permissions
CREATE USER app_user WITH PASSWORD 'secure_password';
GRANT CONNECT ON DATABASE lawinfo TO app_user;
GRANT USAGE ON SCHEMA public TO app_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO app_user;
```