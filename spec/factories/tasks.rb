# Read about factories at https://github.com/thoughtbot/factory_girl
require 'faker'

FactoryGirl.define do
  sequence(:name) { |n| Faker::Lorem.words(2).join(' ') }
  sequence(:date) { |n| date_rand }
  sequence(:done) { |n| [true, false].sample }

  factory :task, aliases: [:pending_task] do
    name 'Buy milk'
    deadline Date.parse('2012-12-21')
    done false

    factory :expired_task do
      deadline Date.yesterday
      done false
    end

    factory :done_task do
      deadline Date.today
      done true
    end

    factory :random_task do
      name { generate(:name) }
      done { generate(:done) }
      deadline { generate(:date) }
    end
  end
end

def date_rand(from = Time.now.beginning_of_week, to = Time.now.end_of_month)
  Time.at(from + rand * (to.to_f - from.to_f))
end
