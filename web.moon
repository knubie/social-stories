lapis = require "lapis"
console = require "lapis.console"
db = require "lapis.db"
import Users, Apps from require "models"
encoding = require "lapis.util.encoding"
import capture_errors, yield_error, respond_to from require "lapis.application"
import validate_functions, assert_valid from require "lapis.validate"
lustache = require "lustache"
random = require "utils/random"

render = (view, model) ->
  io.input("views/#{view}.html")
  model = model or {errors: {}}
  model.errors = model.errors or {}
  lustache\render(io.read("*all"), model)

validate_functions.matches = (input, regex) ->
  string.match(input, regex), "A username can only contain alphanumeric characters (letters A-Z, numbers 0-9) with the exception of underscores."

validate_functions.unique_user = (input, field) ->
  not Users\find("#{field}": input), "#{field} already exists."

validate_functions.password_match = (password, username) ->
  user = Users\find username: username
  user and user.password == encoding.encode_base64(encoding.hmac_sha1(user.salt, password)), "The username and password you entered was not found."

lapis.serve class extends lapis.Application
  "/console": console.make!

  "/": =>
    render 'index',
      username: @session.username

  "/reset": =>
    db.delete "users", "true"

  "/signup": => -- users#new
    render 'signup'

  "/login": respond_to
    GET: => -- sessions#new
      render 'login'

    POST: capture_errors { -- sessions#create
      on_error: =>
        render 'login', {errors: @errors}
      =>
        assert_valid @params, {
          {"username", exists: true}
          {"password", exists: true, password_match: @params.username}
        }

        -- Check consumer token/secret
        -- Assign appropriate access token/secret
        user = Users\find username: @params.username
        app = Apps\find consumer_key: @params.consumer_key
        json
          consumer_key: app.consumer_key
          access_token: app.access_token
          access_secret: app.access_secret

        @session.username = @params.username
        redirect_to: "/"
    }

  "/logout": =>
    @session.username = nil
    "Logged out"

  "/api/v1/users": respond_to
    GET: => -- users#index
      users = Users\select ""
      json: users
    POST: capture_errors { -- users#create
      on_error: =>
        render 'signup', {errors: @errors}
      =>
        assert_valid @params, {
          { "username"
            exists: true
            max_length: 15
            unique_user: "username"
            matches: "^[a-z0-9_]+$" }
          { "password", exists: true }
          { "email", exists: true, min_length: 3, unique_user: "email" }
        }

        -- Encrypt password and create user.
        @params.salt = random.token(25)
        @params.password = encoding.encode_base64(encoding.hmac_sha1(@params.salt, @params.password))
        new_user = Users\create @params

        -- Create default consumer/app.
        Apps\create
          name: "default"
          user_id: new_user.id
          consumer_key: random.token(25)
          consumer_secret: random.token(50)
          --request token (not implemented)
          access_token: "#{new_user.id}-#{random.token(40)}"
          access_token_secret: random.token(45)

        @session.username = new_user.username
        redirect_to: "/"
    }

  "/api/v1/users/:id": => -- users#show
    user = Users\find @params.id
    json: user

  -- OAuth
  "/oauth/request_token": =>
    --6.1.2 "issue unauthorized request_token to client"
    -- server<-->server
    --server - GET-RES /oauth/request_token
    --verify timestamp
    --verify timestamp + nonce
    --verify signature (consumer_key + consumer_secret + nonce + timestamp)
    --generate request_token
    --mark request_token as unauthorized (i.e. verification: null)
    --send request_token
    --send request_secret

  "/oauth/authorize": =>
    -- client<->server
    -- sent: request_token, username, password
    -- verify username/password
    -- mark request_token as authorized (i.e request_token.verification = String)
    -- send 200 request_token, verification

    --@params =
      --oauth_token: "The un-verified request token"
      --oauth_callback: "URL the server redirects the user to."
      --optional:
        --username:
        --password:

    if @params.username
      if user = Users\find username: @params.username
        request_token = RequestTokens\find token: @params.oauth_token
        if request_token and not request_token.verifier
          request_token.verifier = random.token(5)
          json
            oauth_token: @params.oauth_token
            oauth_verifier: request_token.verifier
    else
      "Signin page not yet implemented."

  "/oauth/access_token": =>
    -- server<-->server
    --verify request_signature
    --verify request_token has not been exchanged previously (i.e. that it exists)
    --verify request_token matches consumer_key
    -- (i.e. request_token.app_id == App\find(consumer-id: @params.consumer-id).id)
    --send access_token
    --send access_secret
