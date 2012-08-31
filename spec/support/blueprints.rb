# encoding: utf-8
require 'machinist/active_record'

User.blueprint do
  email           { "User#{sn}@foo.com" }
  password        { "password #{sn}" }
end

Task.blueprint do
  name            { "Task#{sn}" }
end

Client.blueprint do
  name            { "Client#{sn}" }
  user_id         { User.make! }
end

CompletedShift.blueprint do
  start_date      { DateTime.now }
  duration        { "#{sn}" }
  task_id         { Task.make! }
end

WorkShift.blueprint do
  start_time      { Time.now }
  duration        { "#{sn}" }
  user_id         { User.make! }
end

ScheduledShift.blueprint do
  # Attributes here
end

Vacation.blueprint do
  # Attributes here
end
