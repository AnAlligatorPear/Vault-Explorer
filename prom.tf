# Creating K8s Namespaces 
resource "kubernetes_namespace" "prom" {
  metadata {
    annotations = {
      name = var.kubernetes_namespace
    }
    name = var.kubernetes_namespace
  }
}


# Extract Hostname and Port
locals {
  vault_url      = var.vault_address
  vault_hostname = regex("^https?://([^/:]+)", var.vault_address)[0]
  vault_port     = length(regexall(":(\\d+)", var.vault_address)) > 0 ? regexall(":(\\d+)", var.vault_address)[0][0] : "8200"
  protocol       = can(regex("^https?", var.vault_address)[0]) ? regex("^https?", var.vault_address)[0] : "http"

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
      vault_address  = var.vault_address
      vault_token    = var.vault_token
      vault_hostname = local.vault_hostname
      vault_port     = local.vault_port
    })
  ]

}


resource "kubernetes_secret_v1" "vault_token" {
  metadata {
    name      = "vaulttoken"
    namespace = kubernetes_namespace.prom.id
  }
  data = {
    token = var.vault_token
  }
  type = "Opaque" # 


}

resource "kubernetes_secret_v1" "vault_address" {
  metadata {
    name      = "vaultaddress"
    namespace = kubernetes_namespace.prom.id
  }
  data = {
    address = var.vault_address
  }
  type = "Opaque"


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
    "vault.grafana.json" = file("vault.grafana.json")
  }
}