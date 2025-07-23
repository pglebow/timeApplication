variable "aws_region" {
  default = "us-west-2"
}

variable "availability_zones" {
  default = ["us-west-2a", "us-west-2b"]
}

variable "container_image" {
  description = "ECR image URL"
}

variable "route53_zone_id" {
  description = "Route53 Hosted Zone ID for DNS validation"
  type        = string
}
variable "subdomain" {
  description = "The subdomain prefix to use (e.g., 'test' for test.yourdomain.com)"
  type        = string
}
