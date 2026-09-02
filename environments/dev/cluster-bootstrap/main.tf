locals {
  platform     = data.terraform_remote_state.platform.outputs
  cluster_name = local.platform.cluster_name
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"

    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.argocd_chart_version

  wait          = true
  wait_for_jobs = true
  timeout       = 900

  values = [
    yamlencode({
      global = {
        domain = "argocd.local"
      }

      configs = {
        params = {
          # Terminate TLS at the ALB rather than in Argo CD.
          "server.insecure" = true
        }
      }

      controller = {
        replicas = 1
      }

      server = {
        replicas = 1
        service = {
          type = "ClusterIP"
        }
      }

      repoServer = {
        replicas = 1
      }

      applicationSet = {
        replicas = 1
      }

      # Single-node Redis. A lab choice; production runs HA.
      redis-ha = {
        enabled = false
      }
    })
  ]
}

resource "kubernetes_manifest" "root_application" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"

    metadata = {
      name      = "platform"
      namespace = kubernetes_namespace.argocd.metadata[0].name
      finalizers = [
        "resources-finalizer.argocd.argoproj.io",
      ]
    }

    spec = {
      project = "default"

      source = {
        repoURL        = var.gitops_repo_url
        targetRevision = var.gitops_target_revision
        path           = "gitops/platform"

        helm = {
          parameters = [
            { name = "clusterName", value = local.cluster_name },
            { name = "vpcId", value = local.platform.vpc_id },
            { name = "awsRegion", value = var.aws_region },
            { name = "workloadNamespace", value = local.platform.workload_namespace },
            { name = "documentsBucket", value = local.platform.documents_bucket_name },
            { name = "jobsQueueUrl", value = local.platform.jobs_queue_url },
            { name = "jobsQueueName", value = local.platform.jobs_queue_name },
            { name = "databaseSecretName", value = local.platform.database_secret_name },
            { name = "gitopsRepoUrl", value = var.gitops_repo_url },
            { name = "gitopsTargetRevision", value = var.gitops_target_revision },
            { name = "images.ingestApi.repository", value = local.platform.ecr_repository_urls["ingest-api"] },
            { name = "images.metadataWorker.repository", value = local.platform.ecr_repository_urls["metadata-worker"] },
          ]
        }
      }

      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "argocd"
      }

      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
        syncOptions = [
          "CreateNamespace=true",
        ]
      }
    }
  }

  depends_on = [helm_release.argocd]
}