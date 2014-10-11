config = require "lapis.config"

config {"development", "production"}, ->
  postgres ->
    backend "pgmoon"
    host "postgres"
    database "postgres"
