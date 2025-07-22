variable "aws_region" {
  default = "us-west-2"
}

variable "availability_zones" {
  default = ["us-west-2a", "us-west-2b"]
}

variable "container_image" {
  description = "ECR image URL"
}