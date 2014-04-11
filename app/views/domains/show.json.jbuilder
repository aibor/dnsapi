json.domain do
  json.child! do
    json.partial! 'domain', domain: @domain
    json.partial! 'records/records', records: @domain.records
  end
end
