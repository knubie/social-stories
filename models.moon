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
  -- request token (not implemented)
    -- A value used by the Consumer to obtain authorization from the User,
    -- and exchanged for an Access Token.
  -- access_token: "#{user_id}-#{random.token(40)}
    -- A value used by the Consumer to gain access to the Protected Resources
    -- on behalf of the User, instead of using the User’s Service Provider
    -- credentials.
  -- access_token_secret: random.token(45)
    -- A secret used by the Consumer to establish ownership of a given Token.

{:Users, :Stories, :Apps}
