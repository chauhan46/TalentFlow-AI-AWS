# ==========================================
# Security Audit S3 Bucket
# ==========================================

resource "random_id" "audit_bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "audit" {
  bucket = "talentflow-ai-audit-${random_id.audit_bucket_suffix.hex}"

  force_destroy = true

  tags = {
    Name        = "TalentFlow-AI-Audit"
    Project     = "TalentFlow-AI"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# ==========================================
# Audit Bucket Encryption
# ==========================================

resource "aws_s3_bucket_server_side_encryption_configuration" "audit" {
  bucket = aws_s3_bucket.audit.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ==========================================
# Audit Bucket Public Access Block
# ==========================================

resource "aws_s3_bucket_public_access_block" "audit" {
  bucket = aws_s3_bucket.audit.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ==========================================
# AWS Account Information
# ==========================================

data "aws_caller_identity" "current" {}

# ==========================================
# CloudTrail S3 Bucket Policy
# ==========================================

resource "aws_s3_bucket_policy" "audit" {
  bucket = aws_s3_bucket.audit.id

  depends_on = [
    aws_s3_bucket_public_access_block.audit
  ]

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "AWSCloudTrailAclCheck"
        Effect = "Allow"

        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }

        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.audit.arn
      },

      {
        Sid    = "AWSCloudTrailWrite"
        Effect = "Allow"

        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }

        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.audit.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"

        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      },

      {
        Sid    = "AWSConfigBucketPermissionsCheck"
        Effect = "Allow"

        Principal = {
          Service = "config.amazonaws.com"
        }

        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.audit.arn
      },

      {
        Sid    = "AWSConfigBucketDelivery"
        Effect = "Allow"

        Principal = {
          Service = "config.amazonaws.com"
        }

        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.audit.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/Config/*"

        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

# ==========================================
# CloudTrail
# ==========================================

resource "aws_cloudtrail" "talentflow" {
  name                          = "TalentFlow-AI-CloudTrail"
  s3_bucket_name                = aws_s3_bucket.audit.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true

  tags = {
    Name        = "TalentFlow-AI-CloudTrail"
    Project     = "TalentFlow-AI"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }

  depends_on = [
    aws_s3_bucket_policy.audit
  ]
}

# ==========================================
# AWS Config Service-Linked Role
# ==========================================

resource "aws_iam_service_linked_role" "config" {
  aws_service_name = "config.amazonaws.com"
}



# ==========================================
# AWS Config Recorder
# ==========================================

resource "aws_config_configuration_recorder" "talentflow" {
  name     = "TalentFlow-AI-Config-Recorder"
  role_arn = aws_iam_service_linked_role.config.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = false
  }

  depends_on = [
    aws_iam_service_linked_role.config
  ]
}

# ==========================================
# AWS Config Delivery Channel
# ==========================================

resource "aws_config_delivery_channel" "talentflow" {
  name           = "TalentFlow-AI-Config-Delivery"
  s3_bucket_name = aws_s3_bucket.audit.id

  depends_on = [
    aws_s3_bucket_policy.audit
  ]
}

# ==========================================
# Start AWS Config Recorder
# ==========================================

resource "aws_config_configuration_recorder_status" "talentflow" {
  name       = aws_config_configuration_recorder.talentflow.name
  is_enabled = true

  depends_on = [
    aws_config_delivery_channel.talentflow
  ]
}

# ==========================================
# Security Outputs
# ==========================================

output "audit_s3_bucket" {
  description = "Security audit S3 bucket"

  value = aws_s3_bucket.audit.bucket
}

output "cloudtrail_name" {
  description = "CloudTrail trail name"

  value = aws_cloudtrail.talentflow.name
}
