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

  "/signup": =>
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
