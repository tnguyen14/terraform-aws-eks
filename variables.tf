variable "aws_region" {
  description = "AWS Region"
  default     = "us-east-2"
}

variable "cluster_name" {
  description = "Kubernetes Cluster Name"
}

variable "key_name" {
  description = "Name of key for SSH access to worker nodes"
  default     = ""
}
