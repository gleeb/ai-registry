# Project Board

## In-Progress

### Documentation Consolidation and Verification

  - tags: [documentation, consolidation, verification, websocket, agentcore]
  - priority: high
  - workload: Medium
  - defaultExpanded: false
  - steps:
      - [x] Archive SQS polling documentation to separate file for posterity
      - [x] Update backend API documentation with WebSocket endpoints
      - [x] Create comprehensive AgentCore integration documentation
      - [x] Update frontend documentation with WebSocket chat implementation
      - [x] Update infrastructure documentation with current stack structure
      - [x] Document script-based deployment approach for AgentCore
      - [x] Update project board to reflect actual completion status
      - [x] Create WebSocket implementation documentation
      - [x] Document future migration plan from Function URLs to WebSocket
    ```md
    Comprehensive documentation consolidation to align with actual implementation. 
    Successfully archived deprecated SQS polling approach and updated all documentation 
    to reflect current WebSocket-based async agent system and AgentCore integration.
    
    Key updates:
    - WebSocket API endpoints documented
    - AgentCore script-based deployment documented
    - Frontend WebSocket client implementation documented
    - Infrastructure architecture updated with current stack structure
    - Future migration plan documented
    ```

### Inline Agent Enhancement and Optimization

  - tags: [agent, optimization, performance, monitoring, mcp]
  - priority: medium
  - workload: Medium
  - defaultExpanded: false
  - steps:
      - [ ] Performance optimization and monitoring setup
      - [ ] Additional MCP server integrations
      - [ ] Advanced conversation context management
      - [ ] Load testing and scalability validation
      - [ ] Error handling edge case coverage
    ```md
    Enhance and optimize the working inline agent infrastructure. Focus on performance, 
    additional MCP server integrations, and advanced conversation context management.
    ```

## To Do

### MVP Testing and Validation

  - tags: [testing, validation, mvp, pilot]
  - priority: high
  - defaultExpanded: false
  - steps:
      - [ ] Create comprehensive test plan
      - [ ] Conduct unit testing
      - [ ] Perform integration testing
      - [ ] Execute performance testing
      - [ ] Validate with pilot users
      - [ ] Document test results
    ```md
    Comprehensive testing of MVP functionality with pilot users. Ensure all core features
    work reliably before moving to document processing features.
    ```

### Security Implementation

  - tags: [security, encryption, audit, compliance]
  - priority: high
  - workload: Hard
  - defaultExpanded: false
  - steps:
      - [ ] Implement data encryption at rest
      - [ ] Implement data encryption in transit
      - [ ] Add comprehensive audit logging
      - [ ] Apply security best practices
      - [ ] Implement WAF rules
      - [ ] Configure security headers
    ```md
    Implement data encryption, audit logging, and security best practices across all system
    components. Ensure compliance with security requirements.
    ```

### Document Upload API

  - tags: [upload, s3, validation, api]
  - priority: high
  - defaultExpanded: false
  - steps:
      - [ ] Design document upload API
      - [ ] Implement upload endpoint
      - [ ] Integrate with S3
      - [ ] Add file validation
      - [ ] Implement virus scanning
      - [ ] Add upload progress tracking
    ```md
    Implement document upload endpoint with S3 integration and file validation. Support
    multiple file formats and implement proper security measures.
    ```

### Document Processing Lambda

  - tags: [lambda, processing, sqs, async]
  - priority: high
  - workload: Hard
  - defaultExpanded: false
  - steps:
      - [ ] Create document processing Lambda
      - [ ] Integrate with SQS
      - [ ] Implement asynchronous processing
      - [ ] Add error handling and retry logic
      - [ ] Implement processing status updates
    ```md
    Create document processing Lambda with SQS integration for asynchronous processing.
    Handle various document formats and implement robust error handling.
    ```

### Basic OCR Integration

  - tags: [ocr, textract, google-vision, hebrew]
  - priority: high
  - workload: Hard
  - defaultExpanded: false
  - steps:
      - [ ] Implement Amazon Textract integration
      - [ ] Integrate Google Vision API
      - [ ] Configure Hebrew text extraction
      - [ ] Implement OCR quality scoring
      - [ ] Add fallback mechanisms
    ```md
    Implement Amazon Textract and Google Vision API integration for Hebrew text extraction.
    Compare OCR quality and implement intelligent service selection.
    ```

### Text Processing Pipeline

  - tags: [nlp, hebrew, chunking, embeddings]
  - priority: high
  - workload: Hard
  - defaultExpanded: false
  - steps:
      - [ ] Implement Hebrew text normalization
      - [ ] Add semantic chunking algorithm
      - [ ] Generate embeddings
      - [ ] Implement chunk overlap strategy
      - [ ] Add metadata extraction
    ```md
    Implement Hebrew text normalization, semantic chunking, and embedding generation.
    Optimize for legal document structure and Hebrew language characteristics.
    ```

### Vector Search Implementation

  - tags: [vector-search, pgvector, similarity, search]
  - priority: high
  - workload: Hard
  - defaultExpanded: false
  - steps:
      - [ ] Implement vector similarity search
      - [ ] Configure pgvector indexes
      - [ ] Add metadata filtering
      - [ ] Implement relevance scoring
      - [ ] Add search result ranking
    ```md
    Implement vector similarity search using pgvector with metadata filtering.
    Optimize for performance and accuracy in legal document retrieval.
    ```

### RAG Implementation

  - tags: [rag, retrieval, generation, citations]
  - priority: high
  - workload: Hard
  - defaultExpanded: false
  - steps:
      - [ ] Implement Retrieval-Augmented Generation
      - [ ] Add document citations
      - [ ] Implement context assembly
      - [ ] Add source tracking
      - [ ] Implement answer quality scoring
    ```md
    Implement Retrieval-Augmented Generation with document citations and context assembly.
    Ensure accurate source attribution and context relevance.
    ```

### Document Upload UI

  - tags: [ui, upload, progress, validation]
  - priority: medium
  - defaultExpanded: false
  - steps:
      - [ ] Create document upload interface
      - [ ] Add drag-and-drop support
      - [ ] Implement progress tracking
      - [ ] Add file validation UI
      - [ ] Create upload queue management
    ```md
    Create document upload interface with progress tracking and file validation.
    Support bulk uploads and provide clear user feedback.
    ```

### Document Management UI

  - tags: [ui, documents, list, viewer]
  - priority: medium
  - defaultExpanded: false
  - steps:
      - [ ] Implement document list view
      - [ ] Add status tracking
      - [ ] Create basic document viewer
      - [ ] Add search and filtering
      - [ ] Implement document actions
    ```md
    Implement document list, status tracking, and basic document viewer.
    Provide intuitive document management interface.
    ```

### System Monitoring Setup

  - tags: [monitoring, cloudwatch, alerts, health]
  - priority: medium
  - defaultExpanded: false
  - steps:
      - [ ] Configure CloudWatch monitoring
      - [ ] Set up alerting rules
      - [ ] Implement basic health checks
      - [ ] Create monitoring dashboard
    ```md
    Configure CloudWatch monitoring, alerting, and basic health checks for all system components.
    Set up dashboards for real-time system health visibility.
    ```

### WebSocket Integration

  - tags: [websocket, realtime, streaming, updates]
  - priority: medium
  - workload: Hard
  - defaultExpanded: false
  - steps:
      - [ ] Design WebSocket architecture
      - [ ] Implement WebSocket server
      - [ ] Add real-time status updates
      - [ ] Implement chat streaming
      - [ ] Add connection management
    ```md
    Implement real-time updates for document processing status and chat streaming.
    Ensure reliable WebSocket connections with proper fallback mechanisms.
    ```

### Project Management System

  - tags: [projects, access-control, users, management]
  - priority: medium
  - workload: Hard
  - defaultExpanded: false
  - steps:
      - [ ] Design project structure
      - [ ] Implement project creation
      - [ ] Add access control
      - [ ] Create user management
      - [ ] Implement project settings
    ```md
    Implement project creation, access control, and user management features.
    Support multi-tenant architecture with proper isolation.
    ```

### Disaster Recovery Implementation

  - tags: [disaster-recovery, backup, rto, rpo, compliance]
  - priority: medium
  - workload: Hard
  - defaultExpanded: false
  - steps:
      - [ ] Design backup strategy
      - [ ] Implement automated backups
      - [ ] Create point-in-time recovery procedures
      - [ ] Test recovery procedures
      - [ ] Document DR runbooks
      - [ ] Meet RTO/RPO targets of 8h/4h
    ```md
    Implement backup strategy, point-in-time recovery procedures, and meet RTO/RPO targets 
    of 8h/4h. Create comprehensive disaster recovery documentation and runbooks.
    ```

### Hebrew Language Model Evaluation

  - tags: [llm, hebrew, evaluation, benchmarking, bedrock]
  - priority: medium
  - workload: Hard
  - defaultExpanded: false
  - steps:
      - [ ] Design evaluation framework
      - [ ] Evaluate Claude 3.5 Sonnet
      - [ ] Benchmark GPT-4
      - [ ] Test AI21 Jamba
      - [ ] Create performance comparison
      - [ ] Document recommendations
    ```md
    Systematic evaluation and benchmarking of Claude 3.5 Sonnet, GPT-4, and AI21 Jamba 
    for Hebrew legal text processing accuracy and performance.
    ```

### Basic Admin Interface

  - tags: [admin, dashboard, monitoring, users]
  - priority: low
  - defaultExpanded: false
  - steps:
      - [ ] Create admin dashboard
      - [ ] Add user management
      - [ ] Implement system monitoring
    ```md
    Create admin dashboard for user management and system monitoring
    ```

### Hebrew RTL UI Comprehensive Testing

  - tags: [testing, rtl, hebrew, ui, cultural, accessibility]
  - priority: low
  - defaultExpanded: false
  - steps:
      - [ ] Test all UI components for Hebrew RTL support
      - [ ] Verify text rendering
      - [ ] Consider cultural considerations
      - [ ] Test accessibility features
    ```md
    Systematic testing of all UI components for proper Hebrew RTL support, 
    text rendering, and cultural considerations
    ```

### Cost Monitoring and Alerting

  - tags: [cost, monitoring, alerts, optimization, dashboard]
  - priority: low
  - defaultExpanded: false
  - steps:
      - [ ] Create cost tracking system
      - [ ] Build cost dashboard
      - [ ] Track per-query costs
      - [ ] Set up budget alerts
      - [ ] Implement cost optimization
    ```md
    Create dashboard for tracking AWS costs per query/document with budget alerts 
    and usage optimization recommendations.
    ```

### Data Retention Policy System

  - tags: [retention, cleanup, policies, compliance, storage]
  - priority: low
  - defaultExpanded: false
  - steps:
      - [ ] Design retention policy framework
      - [ ] Implement configurable policies
      - [ ] Add automated cleanup
      - [ ] Create retention dashboard
      - [ ] Add compliance reporting
    ```md
    Implement configurable retention policies for documents, chat history, and 
    audit logs with automated cleanup and compliance reporting.
    ```

### Legal Citation Recognition System

  - tags: [ner, legal-terms, hebrew, citations, nlp]
  - priority: low
  - workload: Hard
  - defaultExpanded: false
  - steps:
      - [ ] Research Hebrew legal citation formats
      - [ ] Implement Named Entity Recognition
      - [ ] Add legal terminology extraction
      - [ ] Create citation parser
      - [ ] Build citation graph
    ```md
    Implement Hebrew-specific Named Entity Recognition for legal terminology, 
    citations, and case references. Build comprehensive citation tracking.
    ```

### Human Review System

  - tags: [review, human-loop, quality, corrections]
  - priority: low
  - workload: Hard
  - defaultExpanded: false
  - steps:
      - [ ] Design review workflow
      - [ ] Create review interface
      - [ ] Implement OCR corrections
      - [ ] Add quality metrics
      - [ ] Build reviewer dashboard
    ```md
    Create human-in-the-loop review interface for OCR corrections and quality assurance.
    Track review metrics and improve system accuracy over time.
    ```

### Advanced Document Classification

  - tags: [classification, metadata, document-types]
  - priority: low
  - defaultExpanded: false
  - steps:
      - [ ] Implement automatic document type classification
      - [ ] Add metadata extraction
    ```md
    Implement automatic document type classification and metadata extraction
    ```

### Batch Processing System

  - tags: [batch, bulk, processing, progress]
  - priority: low
  - workload: Hard
  - defaultExpanded: false
  - steps:
      - [ ] Implement bulk document upload
      - [ ] Add batch processing
      - [ ] Include progress tracking
    ```md
    Implement bulk document upload and processing with progress tracking
    ```

### Advanced Search Features

  - tags: [search, filters, sorting, advanced]
  - priority: low
  - defaultExpanded: false
  - steps:
      - [ ] Add search filters
      - [ ] Implement sorting
      - [ ] Create advanced search capabilities
    ```md
    Add filters, sorting, and advanced search capabilities to document search
    ```

### Document Viewer Enhancement

  - tags: [viewer, highlighting, annotations, documents]
  - priority: low
  - defaultExpanded: false
  - steps:
      - [ ] Implement full document viewer
      - [ ] Add highlighting capabilities
      - [ ] Include annotation features
    ```md
    Implement full document viewer with highlighting and annotation capabilities
    ```

### Audio Transcription Integration

  - tags: [audio, transcription, hebrew, transcribe, processing]
  - priority: low
  - defaultExpanded: false
  - steps:
      - [ ] Implement Amazon Transcribe integration
      - [ ] Configure Hebrew audio file processing
    ```md
    Implement Amazon Transcribe integration for Hebrew audio file processing 
    as mentioned in PRD Phase 2
    ```

## Done

### WebSocket Route Cleanup and Frontend Update

  - tags: [websocket, routing, frontend, backend, cleanup]
  - priority: high
  - workload: Medium
  - defaultExpanded: false
  - steps:
      - [x] Create staging document following proper process
      - [x] Create design document for route cleanup
      - [x] Create task plan following Kanban format
      - [x] Remove action-based routing from WebSocket handler
      - [x] Update frontend to use specific routes
      - [x] Fix WebSocket 403 error by adding authorizer to chat route
      - [x] Deploy WebSocket stack with authorizer fix
      - [x] Test complete implementation
      - [x] **CRITICAL DISCOVERY**: AWS WebSocket API only allows authorizers on `$connect` route
      - [x] **SOLUTION IMPLEMENTED**: Reverted to action-based routing with `$default` route
      - [x] **FINAL WORKING SOLUTION**: WebSocket connection working perfectly with action-based routing
    ```md
    Successfully cleaned up WebSocket routing implementation. Initially attempted route-based routing
    but discovered AWS WebSocket API limitations. Final solution uses action-based routing with `$default`
    route, which is the recommended AWS pattern. WebSocket connection, authentication, and message flow
    all working perfectly.
    
    Key learnings:
    - AWS WebSocket API only allows authorizers on `$connect` route
    - Action-based routing is the recommended pattern for non-connection routes
    - Authentication context flows from `$connect` to all subsequent messages
    - Always check AWS service constraints before implementation
    
    Design doc: docs/specs/websocket-route-cleanup/design.md
    Task plan: docs/specs/websocket-route-cleanup/tasks.md
    Implementation: docs/staging/T-044-websocket-route-cleanup.md
    ```

### Project Infrastructure Setup

  - tags: [infra, setup, aws, cdk]
  - priority: high
  - defaultExpanded: false
  - steps:
      - [x] Set up AWS CDK infrastructure
      - [x] Configure CI/CD pipeline
      - [x] Set up development environment
    ```md
    Set up AWS CDK infrastructure, CI/CD pipeline, and development environment
    ```

### Testing Infrastructure Setup

  - tags: [testing, infrastructure, sam, cdk, debugging, vscode]
  - priority: high
  - defaultExpanded: false
  - steps:
      - [x] Set up comprehensive testing infrastructure
      - [x] Configure local Lambda testing using SAM/CDK
      - [x] Integrate VS Code test runner
      - [x] Set up debugging configurations
    ```md
    Set up comprehensive testing infrastructure with local Lambda testing using SAM/CDK, 
    VS Code test runner integration, and proper debugging configurations for all Lambda functions
    ```

### Database Schema Implementation

  - tags: [database, postgresql, schema, pgvector]
  - priority: high
  - workload: Hard
  - defaultExpanded: false
  - steps:
      - [x] Create PostgreSQL schema with pgvector
      - [x] Set up Liquibase for migrations
      - [x] Configure Aurora serverless
      - [x] Build database stack
      - [x] Apply database migrations
    ```md
    Create PostgreSQL schema with pgvector extension for document storage and vector search, 
    use Liquibase for migrations, aurora serverless for database.
    ```

### User Authentication System

  - tags: [auth, cognito, jwt, security]
  - priority: high
  - workload: Hard
  - defaultExpanded: false
  - steps:
      - [x] Create Cognito user pool
      - [x] Configure email domain restrictions
      - [x] Set email as primary identifier
      - [x] Integrate Google identity provider
      - [x] Implement JWT authentication
    ```md
    Implement AWS Cognito integration with JWT-based authentication for API Gateway. 
    Configured with email domain restrictions and Google identity provider.
    ```

### Basic API Gateway Setup

  - tags: [api, gateway, http, cors]
  - priority: high
  - defaultExpanded: false
  - steps:
      - [x] Configure HTTP API Gateway v2
      - [x] Implement authentication
      - [x] Configure CORS
      - [x] Set up rate limiting
    ```md
    Configure HTTP API Gateway v2 with authentication, CORS, and rate limiting
    ```

### Main API Lambda Function

  - tags: [lambda, api, python, health]
  - priority: high
  - defaultExpanded: false
  - steps:
      - [x] Create main API Lambda function
      - [x] Implement user management endpoints
      - [x] Add health check endpoints
    ```md
    Create main API Lambda function with basic user management and health check endpoints
    ```

### Frontend Project Setup

  - tags: [frontend, react, typescript, rtl, hebrew]
  - priority: high
  - defaultExpanded: false
  - steps:
      - [x] Set up React TypeScript project
      - [x] Configure Vite
      - [x] Integrate Ant Design
      - [x] Configure RTL support
    ```md
    Set up React TypeScript project with Vite, Ant Design, and RTL support for Hebrew
    ```

### Authentication UI

  - tags: [ui, auth, login, cognito, components]
  - priority: high
  - defaultExpanded: false
  - steps:
      - [x] Implement login/logout components
      - [x] Integrate with Cognito
    ```md
    Implement login/logout UI components with Cognito integration
    ```

### Chat Interface Components

  - tags: [ui, chat, components, rtl, hebrew]
  - priority: high
  - workload: Hard
  - defaultExpanded: false
  - steps:
      - [x] Create chat interface
      - [x] Implement message bubbles
      - [x] Add input area
      - [x] Configure Hebrew RTL support
      - [x] Build Cognito login flow
    ```md
    Create chat interface with message bubbles, input area, and Hebrew RTL support.
    ```

### Chat with Bedrock Model

  - tags: [chat, bedrock, llm, integration, api, streaming, thought-process]
  - priority: high
  - workload: Hard
  - defaultExpanded: false
  - steps:
      - [x] Implement backend integration
      - [x] Implement frontend integration
      - [x] Enable real-time chat
      - [x] Add message streaming
      - [x] Implement error handling
      - [x] Display thought process
    ```md
    Implement backend and frontend integration to enable real-time chat with AWS Bedrock 
    (Claude 3.5 Sonnet), including message streaming and thought process display.
    ```

### AWS Bedrock Integration

  - tags: [bedrock, claude, llm, chat]
  - priority: high
  - defaultExpanded: false
  - steps:
      - [x] Integrate Claude 3.5 Sonnet
      - [x] Configure fallback models
    ```md
    Integrate Claude 3.5 Sonnet via AWS Bedrock for chat responses with fallback models
    ```

### Chat Session Sidebar Implementation

  - tags: [chat, sessions, sidebar, rtl, dynamodb, gsi, backend]
  - priority: high
  - workload: Hard
  - defaultExpanded: false
  - steps:
      - [x] Implement session management
      - [x] Add backend integration
      - [x] Optimize DynamoDB GSI
      - [x] Implement CRUD operations
      - [x] Create collapsible sidebar
      - [x] Add RTL support
    ```md
    Implement comprehensive chat session management with backend integration, 
    DynamoDB GSI optimization, and collapsible sidebar interface with RTL support
    ```

### Async Chat WebSocket System

  - tags: [chat, websocket, async, real-time, architecture]
  - priority: high
  - workload: Hard
  - defaultExpanded: false
  - steps:
      - [x] Research AWS API Gateway WebSocket APIs and React WebSocket implementations
      - [x] Create comprehensive WebSocket design document
      - [x] Analyze SQS FIFO limitations and pivot to WebSocket approach
      - [x] Create detailed WebSocket task breakdown
      - [x] Set up WebSocket API Gateway infrastructure
      - [x] Implement Connection Manager Lambda function
      - [x] Implement Chat Invoker Lambda function
      - [x] Create frontend WebSocket client with react-use-websocket
      - [x] Integrate async agent with WebSocket messaging
      - [x] Add authentication and connection management
      - [x] Implement comprehensive error handling
      - [x] Fix IAM permissions and VPC configuration issues
      - [x] Test complete WebSocket chat flow end-to-end
    ```md
    Successfully implemented async chat system using AWS API Gateway WebSocket APIs for real-time 
    bidirectional communication. System eliminates API Gateway timeout limitations and provides 
    true real-time communication through WebSocket connections. Frontend and backend integration 
    complete with working authentication, session management, and message flow.
    
    Design doc: docs/specs/async-chat-websocket/design.md
    Task plan: docs/specs/async-chat-websocket/tasks.md
    Staging doc: docs/staging/T-047-chat-message-polling-with-async-agents.md
    ```

### Frontend S3 + CloudFront Deployment

  - tags: [frontend, deployment, s3, cloudfront, auth, waf, infrastructure]
  - priority: high
  - workload: Hard
  - defaultExpanded: false
  - steps:
      - [x] Deploy to S3 bucket
      - [x] Configure CloudFront
      - [x] Update OAuth redirect URLs
      - [x] Configure WAF protection
    ```md
    Deploy frontend to S3 bucket served via CloudFront with proper security configuration
    ```

### Lambda Separation Refactoring

  - tags: [lambda, refactoring, architecture, separation, function-url]
  - priority: high
  - workload: Hard
  - defaultExpanded: false
  - steps:
      - [x] Analyze monolithic bedrock_chat lambda architecture
      - [x] Design new modular lambda architecture
      - [x] Create comprehensive design documentation
      - [x] Extract bedrock_converse lambda for streaming
      - [x] Refactor main_api lambda consolidation
      - [x] Remove unused agent handlers
      - [x] Update CDK infrastructure configuration
      - [x] Fix JWT validation to use Cognito JWKS
      - [x] Update frontend to use new Function URLs
      - [x] Deploy and test complete refactored architecture
    ```md
    Successfully refactored monolithic bedrock_chat lambda into focused, single-purpose lambdas:
    - bedrock_converse: Streaming chat with Function URL
    - main_api: Consolidated non-streaming API Gateway endpoints
    - Removed unused agent handlers
    - Implemented proper Cognito JWKS JWT validation
    - Updated frontend to use new architecture
    - Zero downtime migration with improved performance and maintainability
    
    Design doc: docs/specs/lambda-separation-refactoring/design.md
    Task plan: docs/specs/lambda-separation-refactoring/tasks.md
    Implementation: docs/staging/T-045-lambda-separation-refactoring.md
    ```

### AWS AgentCore Integration

  - tags: [agent, bedrock-agentcore, container, ecr, cdk, streaming]
  - priority: high
  - workload: Hard
  - defaultExpanded: false
  - steps:
      - [x] Create comprehensive design document
      - [x] Research AWS Bedrock AgentCore documentation
      - [x] Design container architecture and runtime contract
      - [x] Implement FastAPI agent runtime
      - [x] Create Dockerfile and build configuration
      - [x] Implement deployment Makefile
      - [x] Deploy MCP server runtimes
      - [x] Deploy async agent runtime
      - [x] Integrate with WebSocket API Gateway
      - [x] Add monitoring and observability
      - [x] Integration testing
      - [x] Documentation and runbooks
    ```md
    Successfully integrated AWS Bedrock AgentCore Runtime with script-based deployment.
    Deployed MCP servers and async agent as containerized services with WebSocket integration.
    Maintains existing agent logic while adding enterprise-grade hosting capabilities.
    
    Design doc: docs/specs/aws-agent-core-integration/design.md
    Task plan: docs/specs/aws-agent-core-integration/tasks.md
    Implementation: docs/staging/T-046-aws-agentcore-mcp-deployment.md
    ```

### AWS Agent Chat Implementation

  - tags: [agent, bedrock, aws, iam, chat, rag, knowledge-base, permissions, ui]
  - priority: high
  - workload: Hard
  - defaultExpanded: false
  - steps:
      - [x] Extract inline agent from bedrock chat into dedicated project
      - [x] Create CDK infrastructure for inline agent Lambda
      - [x] Fix runtime errors (Trace class import, permissions)
      - [x] Configure cross-region inference profile for Claude Sonnet 4
      - [x] Deploy working inline agent infrastructure
      - [x] Implement MCP Server Integration with Context7
      - [x] Integrate with AWS Bedrock Inline Agent API
      - [x] Debug and fix agent response issues
      - [x] Implement comprehensive logging and error handling
      - [x] Fix EventStream processing issues
      - [x] Create agent chat interface and user experience
      - [x] Extract and display agent metadata (thought process, tool calls, citations)
      - [x] Implement real-time chat updates and streaming
      - [x] Integrate with WebSocket system for async agent processing
    ```md
    Successfully implemented AWS Agent Chat with inline agent integration, MCP server support,
    and WebSocket-based async processing. Complete end-to-end system with frontend integration,
    real-time streaming, and comprehensive metadata display.
    
    Design doc: docs/specs/aws-agent-chat/design.md
    Task plan: docs/specs/aws-agent-chat/tasks.md
    Implementation: docs/staging/T-043-inline-agent-backend-completion.md
    ```

## Additional Tasks