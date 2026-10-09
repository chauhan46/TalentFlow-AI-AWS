resource "aws_cloudfront_distribution" "talentflow" {
  enabled = true
  comment = "TalentFlow AI CloudFront Distribution"

  origin {
    domain_name = aws_lb.talentflow.dns_name
    origin_id   = "TalentFlow-AI-ALB"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"

      origin_ssl_protocols = [
        "TLSv1.2"
      ]
    }
  }

  default_cache_behavior {
    target_origin_id       = "TalentFlow-AI-ALB"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = [
      "GET",
      "HEAD",
      "OPTIONS",
      "PUT",
      "POST",
      "PATCH",
      "DELETE"
    ]

    cached_methods = [
      "GET",
      "HEAD"
    ]

    forwarded_values {
      query_string = true

      cookies {
        forward = "all"
      }
    }

    min_ttl     = 0
    default_ttl = 0
    max_ttl     = 0
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  price_class = "PriceClass_100"

  tags = {
    Project     = "TalentFlow-AI"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}