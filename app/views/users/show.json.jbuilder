json.user do
  json.child! do
    json.partial! 'user', user: @user
    json.partial! 'domains/domains', domains: @user.domains
  end
end
