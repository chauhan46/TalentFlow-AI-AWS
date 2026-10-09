# ==========================================
# Route 53 Private Hosted Zone
# ==========================================

resource "aws_route53_zone" "talentflow" {
  name = "talentflow.internal"

  vpc {
    vpc_id = aws_vpc.talentflow.id
  }

  comment = "TalentFlow AI internal DNS zone"

  tags = {
    Name        = "TalentFlow-AI-Private-Zone"
    Project     = "TalentFlow-AI"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# ==========================================
# Internal ALB DNS Record
# ==========================================

resource "aws_route53_record" "talentflow_alb" {
  zone_id = aws_route53_zone.talentflow.zone_id
  name    = "app.talentflow.internal"
  type    = "A"

  alias {
    name                   = aws_lb.talentflow.dns_name
    zone_id                = aws_lb.talentflow.zone_id
    evaluate_target_health = true
  }
}