resource "kubernetes_namespace_v1" "kong_terraform" {
  metadata {
    name = "kong-terraform"

    labels = {
      project     = "kong-kubernetes-lab"
      environment = "terraform-lab"
      managed_by  = "terraform"
    }
  }
}

resource "kubernetes_deployment_v1" "echo" {
  metadata {
    name      = "echo"
    namespace = kubernetes_namespace_v1.kong_terraform.metadata[0].name

    labels = {
      app = "echo"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "echo"
      }
    }

    template {
      metadata {
        labels = {
          app = "echo"
        }
      }

      spec {
        container {
          name  = "echo"
          image = "hashicorp/http-echo:latest"

          args = [
            "-text=Hello from Terraform"
          ]

          port {
            container_port = 5678
          }

          resources {
            requests = {
              cpu    = "50m"
              memory = "32Mi"
            }

            limits = {
              cpu    = "100m"
              memory = "64Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "echo" {
  metadata {
    name      = "echo"
    namespace = kubernetes_namespace_v1.kong_terraform.metadata[0].name
  }

  spec {
    selector = {
      app = "echo"
    }

    port {
      name        = "http"
      port        = 80
      target_port = 5678
    }

    type = "ClusterIP"
  }
}
