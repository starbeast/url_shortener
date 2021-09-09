class ApiTokenSerializer < BaseSerializer
  attributes :expires_at, :alias, :raw_token
end
