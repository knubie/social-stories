import create_table, add_column, types from require "lapis.db.schema"

{
  [1]: =>
    create_table "users", {
      {"id", types.serial}
      {"username", types.varchar}

      {"email", types.varchar}
      {"password", types.varchar}
      {"created_at", types.time}
      {"updated_at", types.time}

      "PRIMARY KEY (id)"
    }
  [2]: =>
    create_table "stories", {
      {"id", types.serial}
      {"user_id", types.foreign_key}

      {"created_at", types.time}
      {"updated_at", types.time}

      "PRIMARY KEY (id)"
    }
  [3]: =>
    add_column "users", "email", types.varchar
    add_column "users", "password", types.varchar
    add_column "users", "created_at", types.time
    add_column "users", "updated_at", types.time
    add_column "stories", "created_at", types.time
    add_column "stories", "updated_at", types.time
  [4]: =>
    create_table "apps", {
      {"id", types.serial}
      {"user_id", types.foreign_key}

      {"name", types.varchar}
      {"consumer_key", types.varchar}
      {"consumer_secret", types.varchar}
      {"access_token", types.varchar}
      {"access_token_secret", types.varchar}

      {"created_at", types.time}
      {"updated_at", types.time}

      "PRIMARY KEY (id)"
    }
  [5]: =>
    add_column "users", "salt", types.varchar
}
