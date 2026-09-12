variable "aws_region" {
  description = "AWS region for the EKS platform"
  type        = string
  default     = "eu-west-2"
}

variable "project_name" {
  description = "Project name used for AWS resources"
  type        = string
  default     = "kong-eks-lab"
}

variable "vpc_cidr" {
  description = "CIDR range for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}
