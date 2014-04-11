json.records(records) do |record|
  json.extract! record, :id, :domain_id, :name, :type, :content, :ttl, :prio, :ordername, :auth, :change_date
  json.url record_url(record, format: :json)
end
