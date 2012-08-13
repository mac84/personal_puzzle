# encoding: utf-8
require 'machinist/active_record'

User.blueprint do
  email           { "User#{sn}@foo.com" }
  password        { "password #{sn}" }
end