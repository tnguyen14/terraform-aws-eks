variable "aws_region" {
  description = "AWS Region"
  default     = "us-east-2"
}

variable "cluster_name" {
  description = "Kubernetes Cluster Name"
}

variable "domain_name" {
  description = "Domain Name for the Load Balancer"
}
