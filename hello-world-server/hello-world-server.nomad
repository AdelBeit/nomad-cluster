job "hello-world-server" {
  datacenters = ["dc1"]
  type        = "service"

  group "web" {
    count = 1

    network {
      mode = "bridge"
      port "http" {
        static = 3000
        to     = 3000
      }
    }

    task "server" {
      driver = "docker"

      config {
        image = "hello-world-server:v1.0.0"
        ports = ["http"]
      }

      resources {
        cpu    = 100
        memory = 256
      }

      service {
        name     = "hello-world-server"
        port     = "http"
        provider = "consul"

        check {
          type     = "http"
          path     = "/"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}