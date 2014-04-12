json.array!(@comments) do |comment|
  json.extract! comment, :id, :domain_id, :name, :type, :modified_at, :account, :comment
  json.url comment_url(comment, format: :json)
end
