output "argocd_namespace" {
  description = "Namespace Argo CD is installed in"
  value       = kubernetes_namespace.argocd.metadata[0].name
}

output "argocd_admin_password_command" {
  description = "Command to retrieve the initial Argo CD admin password"
  value       = "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
}