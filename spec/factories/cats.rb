# Read about factories at https://github.com/thoughtbot/factory_girl

require 'faker'

FactoryGirl.define do
  factory :cat do
    name     { Faker::Name.name } # Why using lamdba here?
    birthday { Faker::Date.birthday }
    visible  true
  end
end
