resource "null_resource" "clone_helm_repo" {
  provisioner "local-exec" {
    command = "rm -rf ./charts && git clone https://github.com/elayvilkom/status_page.git ./charts"
  }

  triggers = {
    always_run = "${timestamp()}"
  }
}

provider "helm" {
  kubernetes {
    config_path = "/home/ubuntu/.kube/config"
  }
}

resource "helm_release" "argocd" {
  name             = "argocd"
  namespace        = "argocd"
  chart            = "../helm-charts/argocd-helm"
  create_namespace = true


  depends_on = [null_resource.clone_helm_repo]
}