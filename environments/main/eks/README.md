

export KUBECONFIG=~/dev/infrastructure/terraform/environments/main/eks/kubeconfig_eks-cluster-main-eu-west-1

jx install --provider=eks --domain=example.com --default-environment-prefix=example
