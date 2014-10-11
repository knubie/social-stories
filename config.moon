config = require "lapis.config"

config {"development", "production"}, ->
  postgres ->
    backend "pgmoon"
    host "172.17.0.24"
    database "postgres"
