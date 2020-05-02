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

variable "key_name" {
  description = "Name of key for SSH access to worker nodes"
  default     = ""
}
