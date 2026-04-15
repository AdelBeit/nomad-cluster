job "hello-world-client" {
  datacenters = ["dc1"]
  type        = "service"

  group "web" {
    count = 1

    network {
      mode = "bridge"
      port "http" {
        static = 8080
        to     = 80
      }
    }

    task "client" {
      driver = "docker"

      config {
        image = "hello-world-client:v1.0.0"
        ports = ["http"]
      }

      resources {
        cpu    = 50
        memory = 64
      }
    }
  }
}
