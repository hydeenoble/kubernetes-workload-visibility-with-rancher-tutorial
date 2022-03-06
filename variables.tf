variable "tags" {
  description = "A map of tags to assign to the resource"
  default = {
    Application = "kubernetes-workload-visibility-with-rancher-tutorial"
    Team        = "Guest-Writer"
    Environment = "Development"
    Managed-By  = "Terraform"
  }
}

variable "region" {
  default = "eu-west-1"
}

variable "rancher_key_pair_key_pair" {}

variable "aws_account_id" {}

variable "iam_username" {}