variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "eu-west-2"
}

variable "app_name" {
  description = "Name used to tag and name all resources"
  type        = string
  default     = "it-tools"
}

variable "domain_name" {
  description = "Root domain name"
  type        = string
  default     = "hassanuur.co.uk"
}

variable "app_domain" {
  description = "Full subdomain for the app"
  type        = string
  default     = "tm.hassanuur.co.uk"
}

variable "container_image" {
  description = "Full ECR image URI including tag"
  type        = string
}

variable "task_cpu" {
  description = "CPU units for the ECS task"
  type        = string
  default     = "256"
}

variable "task_memory" {
  description = "Memory in MB for the ECS task"
  type        = string
  default     = "512"
}

variable "desired_count" {
  description = "Number of ECS tasks to run"
  type        = number
  default     = 1
}