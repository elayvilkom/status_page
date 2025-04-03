# Kubernetes Provider (update path as needed)
provider "kubernetes" {
  config_path = "/home/ubuntu/.kube/config"
}

# Load IAM policy JSON from GitHub
data "http" "lb_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.7.2/docs/install/iam_policy.json"
}

# Create IAM policy from the JSON
resource "aws_iam_policy" "aws_lb_controller_policy" {
  name   = "AWSLoadBalancerControllerIAMPolicy"
  policy = data.http.lb_policy.body
}

# Get EKS cluster OIDC details
data "aws_eks_cluster" "cluster" {
  name = "elay-noa-k8s-cluster"
}

data "aws_iam_openid_connect_provider" "oidc" {
  url = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

# Create IAM assume role policy
data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.oidc.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }
  }
}

# Create IAM role for the load balancer controller
resource "aws_iam_role" "lb_controller_role" {
  name               = "AmazonEKSLoadBalancerControllerRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "attach_lb_policy" {
  policy_arn = aws_iam_policy.aws_lb_controller_policy.arn
  role       = aws_iam_role.lb_controller_role.name
}

# Create the Kubernetes ServiceAccount with annotation for the IAM role
resource "kubernetes_service_account" "aws_lb_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.lb_controller_role.arn
    }
  }
}