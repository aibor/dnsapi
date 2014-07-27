json.extract! user, :id, :username, :admin
json.url user_url(user, format: :json)
