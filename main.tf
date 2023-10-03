terraform {
  required_version = ">= 0.13.1"

  required_providers {
    shoreline = {
      source  = "shorelinesoftware/shoreline"
      version = ">= 1.11.0"
    }
  }
}

provider "shoreline" {
  retries = 2
  debug = true
}

module "excessive_load_on_cassandra" {
  source    = "./modules/excessive_load_on_cassandra"

  providers = {
    shoreline = shoreline
  }
}