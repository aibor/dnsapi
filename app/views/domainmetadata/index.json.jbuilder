json.array!(@domainmetadata) do |domainmetadatum|
  json.extract! domainmetadatum, :id, :domain_id, :kind, :content
  json.url domainmetadatum_url(domainmetadatum, format: :json)
end
