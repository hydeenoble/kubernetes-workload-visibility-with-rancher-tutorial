module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "demo-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets = []
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = var.tags
}

resource "aws_key_pair" "key_pair" {
  key_name   = "rancher-kp"
  public_key = var.rancher_key_pair_key_pair
}

resource "aws_security_group" "rancher_security_group" {
  name        = "rancher"
  description = "Allow TLS inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description      = "TLS from Anywhere"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "HTTP from Anywhere"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "SSH from Anywhere"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(var.tags, {
    Name = "rancher"
  })
}

# VvJc3wlHGSiVs6ve
module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "rancher"

  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.medium"
  key_name               = aws_key_pair.key_pair.key_name
  monitoring             = false
  vpc_security_group_ids = [aws_security_group.rancher_security_group.id]
  subnet_id              = module.vpc.public_subnets[0]

  tags = var.tags
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 17.24.0"

  cluster_version = "1.21"
  cluster_name    = local.eks_name
  vpc_id          = module.vpc.vpc_id
  subnets         = module.vpc.public_subnets
  map_users       = local.eks_iam_users
  map_roles       = []

  cluster_endpoint_private_access                = false
  cluster_endpoint_public_access                 = true
  # cluster_create_endpoint_private_access_sg_rule = false
  # cluster_endpoint_private_access_cidrs          = [var.vpn_client_cidr_block]
  # cluster_endpoint_private_access_sg             = var.create_shared_resource ? [module.vpn_jumpcloud[0].security_group_id] : var.vpn_sg_id

  kubeconfig_aws_authenticator_command = "aws"
  kubeconfig_aws_authenticator_command_args = [
    "eks", "get-token", "--cluster-name", local.eks_name, "--region", var.region
  ]

  worker_sg_ingress_from_port = "0"
  node_groups_defaults = {
    ami_type    = "AL2_x86_64"
    disk_size   = 50
    name        = "${local.eks_name}-node"
    name_prefix = "${local.eks_name}-node"
  }

  node_groups = {
    node_group = {
      name             = "${local.eks_name}-node-group"
      min_capacity     = 1
      max_capacity     = 1
      desired_capacity = 1

      instance_types = ["t2.medium"]
      capacity_type  = "SPOT"

      update_config = {
        max_unavailable_percentage = 50
      }

      k8s_labels = merge(var.tags, { "Name" : "${local.eks_name}-node" })

      additional_tags = merge(var.tags, { "Name" : "${local.eks_name}-node" })
    }
  }

  tags = var.tags
}
