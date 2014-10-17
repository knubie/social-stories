import Model from require "lapis.db.model"
import create_table, types from "lapis.db.schema"

-- columns: id, username, email, password, salt
class Users extends Model
  @timestamp: true

-- columns: id, user_id
class Stories extends Model
  @timestamp: true

-- columns: id, user_id, name, consumer_key, consumer_secret, request_token, access_token, token_secret
class Apps extends Model
  @timestamp: true
  -- consumer_key: random.token(25)
    -- A value used by the Consumer to identify itself to the Service Provider.
  -- consumer_secret: random.token(50)
    -- A secret used by the Consumer to establish ownership of the Consumer Key.

class RequestTokens extends Model
  -- id: Integer
  -- user_id: foreign-key
  -- app_id: foreign-key
  -- token: random.token(45)
  -- secret: random.token(40)
  -- verifier: random.token(40)

class AccessTokens extends Model
  -- id: Integer
  -- user_id: foreign-key
  -- app_id: foreign-key
  -- token: random.token(40)
  -- secret: random.token(45)

{:Users, :Stories, :Apps, :RequestTokens, :AccessTokens}
