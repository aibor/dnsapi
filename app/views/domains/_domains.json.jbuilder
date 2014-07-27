json.domains(domains) do |domain|
  json.partial! domain, domain: domain
end
