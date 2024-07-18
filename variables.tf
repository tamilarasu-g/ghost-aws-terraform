variable "aws-required-region" {
  description = "The region where the aws resources are created"
  default     = "ap-south-1"
}

variable "instance-id" {
  description = "Id of the instance which runs ghost"
}

variable "domain" {
  description = "Domain of the ghost instance"
}

variable "a-record-policy-path" {
  description = "The path containing the policy document for create-a-record-role"
  default     = "./policies/create-a-record.json"
}

variable "volume-start-instance-policy-path" {
  description = "The path containing the policy document for create-volume-start-instace-role"
  default     = "./policies/create-volume-start-instance.json"
}

variable "snap-and-delete-volume-policy-path" {
  description = "The path containing the policy document for snap-and-delete-volume-role"
  default     = "./policies/snap-and-delete-volume.json"
}

variable "create-a-record-lambda-file" {
  description = "Lambda function file for create-a-record"
  default     = "./python/create-a-record.py.tpl"
}

variable "create-volume-instance-lambda-file" {
  description = "Lambda function file for create volume and start the instance"
  default     = "./python/create-volume-start-instance.py.tpl"
}

variable "snap-and-delete-volume-lambda-file" {
  description = "Lambda function file for snap and delete volume"
  default     = "./python/snap-and-delete-volume.py.tpl"
}

variable "root-device-name" {
  description = "simple"
  default     = "/dev/sda1"
}

variable "ec2-ghost-start-rule-path" {
  default = "./eventbridge-rules/ec2-ghost-start.json.tpl"
}

variable "ec2-ghost-stop-rule-path" {
  default = "./eventbridge-rules/ec2-ghost-stop.json.tpl"
}

variable "netlify_access_token" {
  description = "The access token of netlify to change the dns records of the domain"
}