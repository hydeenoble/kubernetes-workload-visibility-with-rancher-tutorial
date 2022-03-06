locals {
    eks_name = "demo-eks"
  eks_iam_users = [
    {
      userarn  = "arn:aws:iam::${var.aws_account_id}:user/${var.iam_username}"
      username = var.iam_username
      groups   = ["system:masters"]
    }
  ]
}