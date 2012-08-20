# encoding: utf-8
require 'machinist/active_record'

User.blueprint do
  email           { "User#{sn}@foo.com" }
  password        { "password #{sn}" }
end

Task.blueprint do
  name            { "name#{sn}" }
end

Client.blueprint do
  name            { "name#{sn}" }
end


CompletedShift.blueprint do
  # Attributes here
end
