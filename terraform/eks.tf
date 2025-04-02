module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.34.0"

  cluster_name    = "elay-noa-k8s-cluster"
  cluster_version = "1.32"
  subnet_ids      = [
    aws_subnet.private_subnet.id,
    aws_subnet.private_subnet1.id
  ]
  vpc_id = aws_vpc.my_vpc.id

  cluster_endpoint_public_access       = true
  cluster_endpoint_private_access      = true
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]

  eks_managed_node_group_defaults = {
    instance_types = ["t3.medium"]
    ami_type       = "AL2_x86_64"
  }

  eks_managed_node_groups = {
    statuspage_app_nodes = {
      desired_size = 2
      min_size     = 1
      max_size     = 3
    }
  }

  enable_cluster_creator_admin_permissions = true

  tags = {
    Name  = "elay-noa-k8s-cluster"::
    owner = "elayvilkom"
  }
}
