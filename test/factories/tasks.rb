# frozen_string_literal: true

FactoryBot.define do
  factory :task do
    name { 'My task' }
    active

    trait :active do
      status { 'active' }
    end

    trait :inactive do
      status { 'inactive' }
    end
  end
end
