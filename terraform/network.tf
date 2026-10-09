data "aws_availability_zones" "available" {
  state = "available"
}

# -----------------------------
# VPC
# -----------------------------
resource "aws_vpc" "talentflow" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "TalentFlow-AI-VPC"
    Project     = "TalentFlow-AI"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# -----------------------------
# Internet Gateway
# -----------------------------
resource "aws_internet_gateway" "talentflow" {
  vpc_id = aws_vpc.talentflow.id

  tags = {
    Name        = "TalentFlow-AI-IGW"
    Project     = "TalentFlow-AI"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# -----------------------------
# Public Subnet 1
# -----------------------------
resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.talentflow.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name        = "TalentFlow-AI-Public-Subnet-1"
    Project     = "TalentFlow-AI"
    Environment = "Production"
    Tier        = "Public"
    ManagedBy   = "Terraform"
  }
}

# -----------------------------
# Public Subnet 2
# -----------------------------
resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.talentflow.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name        = "TalentFlow-AI-Public-Subnet-2"
    Project     = "TalentFlow-AI"
    Environment = "Production"
    Tier        = "Public"
    ManagedBy   = "Terraform"
  }
}

# -----------------------------
# Private Subnet 1
# -----------------------------
resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.talentflow.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name        = "TalentFlow-AI-Private-Subnet-1"
    Project     = "TalentFlow-AI"
    Environment = "Production"
    Tier        = "Private"
    ManagedBy   = "Terraform"
  }
}

# -----------------------------
# Private Subnet 2
# -----------------------------
resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.talentflow.id
  cidr_block        = "10.0.12.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name        = "TalentFlow-AI-Private-Subnet-2"
    Project     = "TalentFlow-AI"
    Environment = "Production"
    Tier        = "Private"
    ManagedBy   = "Terraform"
  }
}

# -----------------------------
# Public Route Table
# -----------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.talentflow.id

  tags = {
    Name        = "TalentFlow-AI-Public-RT"
    Project     = "TalentFlow-AI"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.talentflow.id
}

# -----------------------------
# Public Route Associations
# -----------------------------
resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

# -----------------------------
# Private Route Table
# -----------------------------
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.talentflow.id

  tags = {
    Name        = "TalentFlow-AI-Private-RT"
    Project     = "TalentFlow-AI"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# -----------------------------
# Private Route Associations
# -----------------------------
resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private.id
}

# -----------------------------
# Web Security Group
# -----------------------------
resource "aws_security_group" "web" {
  name        = "TalentFlow-AI-Web-SG"
  description = "Security group for TalentFlow AI web servers"
  vpc_id      = aws_vpc.talentflow.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "TalentFlow-AI-Web-SG"
    Project     = "TalentFlow-AI"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# -----------------------------
# RDS Security Group
# -----------------------------
resource "aws_security_group" "rds" {
  name        = "TalentFlow-AI-RDS-SG"
  description = "Security group for TalentFlow AI database"
  vpc_id      = aws_vpc.talentflow.id

  ingress {
    description     = "MySQL from web servers"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "TalentFlow-AI-RDS-SG"
    Project     = "TalentFlow-AI"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}