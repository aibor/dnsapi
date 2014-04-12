json.array!(@cryptokeys) do |cryptokey|
  json.extract! cryptokey, :id, :domain_id, :flags, :active, :content
  json.url cryptokey_url(cryptokey, format: :json)
end
