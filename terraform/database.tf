# ==========================================
# RDS Subnet Group
# ==========================================

resource "aws_db_subnet_group" "talentflow" {
  name = "talentflow-ai-db-subnet-group"

  subnet_ids = [
    aws_subnet.private_1.id,
    aws_subnet.private_2.id
  ]

  tags = {
    Name        = "TalentFlow-AI-DB-Subnet-Group"
    Project     = "TalentFlow-AI"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# ==========================================
# RDS Password
# ==========================================

resource "random_password" "db_password" {
  length           = 20
  special          = true
  override_special = "!#$%^&*()-_=+"
}

# ==========================================
# RDS MySQL
# ==========================================

resource "aws_db_instance" "talentflow" {
  identifier = "talentflow-ai-db"

  engine         = "mysql"
  engine_version = "8.0"

  instance_class        = "db.t3.micro"
  allocated_storage     = 20
  max_allocated_storage = 20
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = "talentflow"
  username = "talentflowadmin"
  password = random_password.db_password.result

  port = 3306

  db_subnet_group_name   = aws_db_subnet_group.talentflow.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  publicly_accessible = false

  multi_az = false

  backup_retention_period = 1
  backup_window           = "03:00-04:00"

  maintenance_window = "sun:04:00-sun:05:00"

  auto_minor_version_upgrade = true

  deletion_protection = false
  skip_final_snapshot = true

  tags = {
    Name        = "TalentFlow-AI-RDS"
    Project     = "TalentFlow-AI"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# ==========================================
# S3 Bucket
# ==========================================

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "talentflow" {
  bucket = "talentflow-ai-storage-${random_id.bucket_suffix.hex}"

  force_destroy = true

  tags = {
    Name        = "TalentFlow-AI-S3"
    Project     = "TalentFlow-AI"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# ==========================================
# S3 Versioning
# ==========================================

resource "aws_s3_bucket_versioning" "talentflow" {
  bucket = aws_s3_bucket.talentflow.id

  versioning_configuration {
    status = "Enabled"
  }
}

# ==========================================
# S3 Encryption
# ==========================================

resource "aws_s3_bucket_server_side_encryption_configuration" "talentflow" {
  bucket = aws_s3_bucket.talentflow.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ==========================================
# S3 Public Access Block
# ==========================================

resource "aws_s3_bucket_public_access_block" "talentflow" {
  bucket = aws_s3_bucket.talentflow.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
