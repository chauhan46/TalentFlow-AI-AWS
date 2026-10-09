# TalentFlow AI – AWS Cloud Implementation

## Project Overview

TalentFlow AI is a recruitment and talent management application implemented using a production-style AWS cloud architecture.

The project demonstrates secure networking, scalable compute, database and storage services, serverless components, monitoring, auditing, DNS, CDN, Infrastructure as Code, and event-driven architecture.

---

## AWS Services Used

- Amazon VPC
- Amazon EC2
- EC2 Auto Scaling
- Application Load Balancer
- Amazon RDS MySQL
- Amazon S3
- AWS Lambda
- Amazon API Gateway
- Amazon SQS
- Amazon SNS
- Amazon EventBridge
- Amazon CloudWatch
- AWS CloudTrail
- AWS Config
- Amazon Route 53
- Amazon CloudFront
- AWS IAM

---

## Architecture

The TalentFlow AI infrastructure is deployed using a multi-tier AWS architecture.

### Network Layer

- Amazon VPC
- Public Subnets
- Private Subnets
- Internet Gateway
- Route Tables
- Security Groups

### Compute Layer

- Amazon EC2
- Auto Scaling Group
- Application Load Balancer

### Database & Storage Layer

- Amazon RDS MySQL
- Amazon S3

### Serverless & Event Layer

- API Gateway
- AWS Lambda
- Amazon SQS
- Amazon SNS
- Amazon EventBridge

### Monitoring & Security Layer

- Amazon CloudWatch
- AWS CloudTrail
- AWS Config
- AWS IAM

### Delivery Layer

- Amazon CloudFront
- Amazon Route 53

---

## Network Configuration

The project uses a dedicated VPC with the following configuration:

- **VPC CIDR:** `10.0.0.0/16`
- **Public Subnets:** 2
- **Private Subnets:** 2
- **Internet Gateway:** Configured
- **Public Route Table:** Configured
- **Private Route Table:** Configured
- **Security Groups:** Configured

The Application Load Balancer is deployed across the public subnets, while database resources are placed within the private network.

---

## Compute

Amazon EC2 is used as the application compute layer.

An Auto Scaling Group is configured to maintain multiple EC2 instances and provide availability and scalability.

The Application Load Balancer distributes incoming traffic to healthy EC2 instances through the configured target group.

---

## Database and Storage

### Amazon RDS

Amazon RDS for MySQL is used as the relational database layer.

### Amazon S3

Amazon S3 is used for application storage and audit-related storage requirements.

---

## Serverless Architecture

AWS Lambda is used for serverless processing.

Amazon API Gateway provides the HTTP API endpoint and routes requests to the Lambda function.

The project also includes:

- Amazon SQS for asynchronous message processing
- Amazon SNS for notifications
- Amazon EventBridge for event-driven processing

---

## Monitoring

Amazon CloudWatch is used for monitoring and alerting.

The following alarms were configured:

- `TalentFlow-AI-EC2-High-CPU`
- `TalentFlow-AI-RDS-High-CPU`
- `TalentFlow-AI-ALB-5XX`
- `TalentFlow-AI-Lambda-Errors`

---

## Security and Compliance

The project uses AWS-native security and auditing services.

### IAM

IAM roles and policies are used to provide controlled access to AWS resources.

### AWS CloudTrail

CloudTrail is used to record AWS API activity for auditing purposes.

### AWS Config

AWS Config is used to record and monitor AWS resource configuration.

### Amazon S3 Security

S3 public access controls and server-side encryption are configured for audit storage.

---

## DNS and CDN

### Amazon Route 53

A private hosted zone is configured:

`talentflow.internal`

### Amazon CloudFront

Amazon CloudFront is used as the CDN layer for content delivery.

---

## Infrastructure as Code

Terraform is used to provision and manage the AWS infrastructure.

The Terraform configuration covers:

- Networking
- Compute
- Load Balancing
- Database
- Storage
- Serverless services
- Monitoring
- Security
- DNS
- CDN

---

## Validation

The deployed infrastructure was validated using Terraform and AWS CLI.

The following components were successfully validated:

- EC2 instances – Healthy / InService
- Auto Scaling Group – Operational
- ALB target group – Healthy
- RDS MySQL – Available
- S3 – Available
- Lambda – Active
- SQS – Available
- SNS – Available
- EventBridge – Enabled
- CloudWatch alarms – OK
- CloudTrail – Logging enabled
- AWS Config – Recording successfully
- CloudFront – Deployed
- Route 53 – Private hosted zone available
- API Gateway – Configured
- Terraform – Infrastructure managed through Terraform state

---

## Application

TalentFlow AI provides recruitment and talent-management functionality through the following application areas:

- Dashboard
- Candidates
- Job Openings
- Scheduled Interviews
- Hiring Pipeline
- Recruitment Analytics
- Settings

The supplied frontend/demo application provides the application interface and demonstration functionality.

---

## Project Structure

```text
TalentFlow-AI-AWS/
│
├── terraform/
│   ├── provider.tf
│   ├── network.tf
│   ├── compute.tf
│   ├── database.tf
│   ├── serverless.tf
│   ├── monitoring.tf
│   ├── security.tf
│   ├── cloudfront.tf
│   └── ...
│
├── lambda/
│   └── lambda_function.py
│
├── README.md
└── ...