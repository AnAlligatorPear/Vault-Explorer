# Creating K8s Namespaces 
resource "kubernetes_namespace" "prom" {
  metadata {
    annotations = {
      name = var.kubernetes_namespace
    }
    name = var.kubernetes_namespace
  }
}

# Deploying Prometheus + Grafana 
resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = kubernetes_namespace.prom.id
  version    = var.prom_version

  # Load the existing YAML configuration and marge the templatefile with the prometheus yaml
    values = [
            templatefile("${path.module}/prom.stack.values.yml.tftpl", {
              vault_address = var.vault_address
              vault_token  = var.vault_token
            })
      ]
}
/*
  values = [
    "${file("prom.stack.values.yml")}"
  ]
  }

*/


resource "kubernetes_secret_v1" "vault_token" {
  metadata {
    name = "vaulttoken"
    namespace  = kubernetes_namespace.prom.id
  }

  data = {
    token = var.vault_token
  }

  type = "kubernetes.io/opaque"
}


resource "kubernetes_config_map" "grafana-dashboards-vault" {
  metadata {
    name      = "grafana-dashboard-vault"
    namespace = kubernetes_namespace.prom.id

    labels = {
      grafana_dashboard = 1
    }

    annotations = {
      k8s-sidecar-target-directory = "/tmp/dashboards/vault"
    }
  }

  data = {
    "vault.grafana.json"        = file("vault.grafana.json")
  }
}