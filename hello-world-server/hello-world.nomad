job "hello-world" {
  datacenters = ["dc1"]
  type        = "service"

  constraint {
    attribute = "${attr.consul.version}"
    operator  = "is_not_set"
  }

  group "web" {
    count = 1

    network {
      mode = "bridge"
      port "http" {
        to = 3000
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
    }
  }
}