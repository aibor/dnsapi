json.array!(@tsigkeys) do |tsigkey|
  json.extract! tsigkey, :id, :name, :algorithm, :secret
  json.url tsigkey_url(tsigkey, format: :json)
end
