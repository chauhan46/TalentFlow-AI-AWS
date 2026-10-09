# ==========================================
# EC2 IAM Role
# ==========================================

resource "aws_iam_role" "ec2_role" {
  name = "TalentFlow-AI-EC2-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "TalentFlow-AI-EC2-Role"
    Project     = "TalentFlow-AI"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2" {
  name = "TalentFlow-AI-EC2-Profile"
  role = aws_iam_role.ec2_role.name
}

# ==========================================
# Latest Amazon Linux 2023 AMI
# ==========================================

data "aws_ssm_parameter" "amazon_linux" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

# ==========================================
# ALB Security Group
# ==========================================

resource "aws_security_group" "alb" {
  name        = "TalentFlow-AI-ALB-SG"
  description = "Security group for TalentFlow AI ALB"
  vpc_id      = aws_vpc.talentflow.id

  ingress {
    description = "HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from Internet"
    from_port   = 443
    to_port     = 443
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
    Name        = "TalentFlow-AI-ALB-SG"
    Project     = "TalentFlow-AI"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# ==========================================
# Launch Template
# ==========================================

resource "aws_launch_template" "talentflow" {
  name_prefix   = "TalentFlow-AI-"
  image_id      = data.aws_ssm_parameter.amazon_linux.value
  instance_type = "t3.micro"

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2.name
  }

  vpc_security_group_ids = [
    aws_security_group.web.id
  ]

  user_data = base64encode(<<-EOF
    #!/bin/bash

    dnf update -y
    dnf install -y nginx

    systemctl enable nginx
    systemctl start nginx

    cat > /usr/share/nginx/html/index.html <<'HTML'
    <!DOCTYPE html>
    <html>
    <head>
      <title>TalentFlow AI</title>
      <style>
        body {
          font-family: Arial, sans-serif;
          text-align: center;
          margin-top: 100px;
        }
        h1 {
          font-size: 42px;
        }
        p {
          font-size: 20px;
        }
      </style>
    </head>
    <body>
      <h1>TalentFlow AI</h1>
      <p>AWS deployment successful</p>
      <p>Server: EC2 Auto Scaling Group</p>
    </body>
    </html>
    HTML
  EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name        = "TalentFlow-AI-EC2"
      Project     = "TalentFlow-AI"
      Environment = "Production"
      ManagedBy   = "Terraform"
    }
  }
}

# ==========================================
# Application Load Balancer
# ==========================================

resource "aws_lb" "talentflow" {
  name               = "talentflow-ai-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.alb.id
  ]

  subnets = [
    aws_subnet.public_1.id,
    aws_subnet.public_2.id
  ]

  tags = {
    Name        = "TalentFlow-AI-ALB"
    Project     = "TalentFlow-AI"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# ==========================================
# Target Group
# ==========================================

resource "aws_lb_target_group" "talentflow" {
  name     = "talentflow-ai-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.talentflow.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    path                = "/"
    matcher             = "200"
  }

  tags = {
    Name        = "TalentFlow-AI-TG"
    Project     = "TalentFlow-AI"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# ==========================================
# ALB Listener
# ==========================================

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.talentflow.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "forward"

    target_group_arn = aws_lb_target_group.talentflow.arn
  }
}

# ==========================================
# Auto Scaling Group
# ==========================================

resource "aws_autoscaling_group" "talentflow" {
  name = "TalentFlow-AI-ASG"

  min_size         = 2
  desired_capacity = 2
  max_size         = 2

  health_check_type         = "ELB"
  health_check_grace_period = 180

  vpc_zone_identifier = [
    aws_subnet.public_1.id,
    aws_subnet.public_2.id
  ]

  target_group_arns = [
    aws_lb_target_group.talentflow.arn
  ]

  launch_template {
    id      = aws_launch_template.talentflow.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "TalentFlow-AI-ASG-Instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = "TalentFlow-AI"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = "Production"
    propagate_at_launch = true
  }

  tag {
    key                 = "ManagedBy"
    value               = "Terraform"
    propagate_at_launch = true
  }
}
