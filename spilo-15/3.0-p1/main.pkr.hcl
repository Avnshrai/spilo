packer {
  required_plugins {
    docker = {
      version = ">= 0.0.7"
      source  = "github.com/hashicorp/docker"
    }
  }
}

source "docker" "spilo" {
  image  = "ubuntu:jammy"  # Adjust the base image according to your requirements
  commit = true
  volumes = {
    "/var/run/docker.sock" = "/var/run/docker.sock"
  }
}
variable "docker_username" {
  type    = string
  default = ""
}
variable "docker_password" {
  type    = string
  default = ""
}
variable "tag" {
  type    = string
  default = ""
}
variable "git_token" {
  type    = string
  default = ""
}
variable "spilo_version" {
  type    = string
  default = ""
}
variable "gopath" {
  type    = string
  default = ""
}
variable "branch" {
  type    = string
  default = ""
}
build {
  name = "Percona-postgres-server-Image"
  sources = [
    "source.docker.percona-postgres-server"
  ]
  provisioner "shell" {
    inline = [
      "apt-get update",
      "DEBIAN_FRONTEND=noninteractive apt-get install -y make curl wget jq ca-certificates git gnupg lsb-release sudo software-properties-common",
      "sudo apt-get install -y docker.io",
      "sudo apt install docker-buildx",
      "git clone https://github.com/Avnshrai/spilo.git",
      "cd spilo && git checkout tags/${var.branch}",
      "cd postgres-appliance",
      "docker build -t avnshrai/postgres-spilo:${var.tag} .",
      "docker tag avnshrai/postgres-spilo:${var.tag} avnshrai/postgres-spilo:latest",
      "docker login -u ${var.docker_username} -p ${var.docker_password}",
      "docker push avnshrai/postgres-spilo:${var.tag}",
      "docker push avnshrai/postgres-spilo:latest",
    ]
  }

  post-processor "docker-tag" {
    repository = "avnshrai/postgres-spilo"  # Adjust repository name as needed
    tags       = ["latest"]
  }
}
