resource "helm_release" "my_chart" {
  depends_on = [aws_eks_node_group.eks_nodes]

  name       = "my-release"
  chart      = "./my-chart"  # Path to your local Helm chart directory
  namespace  = "default"     # Namespace to deploy the chart
  wait       = true          # Wait for the deployment to complete

  # Optional: Set values for the Helm chart
  set {
    name  = "service.type"
    value = "ClusterIP"
  }
}