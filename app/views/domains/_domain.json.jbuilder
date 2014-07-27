json.extract! domain, :id, :name, :master, :last_check, :type, :notified_serial
json.url domain_url(domain, format: :json)
