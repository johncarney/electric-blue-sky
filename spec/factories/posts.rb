# frozen_string_literal: true

FactoryBot.define do
  factory :post do
    transient do
      text { Faker::Lorem.paragraph }
    end

    uri  { Faker::Internet.url }
    repo { Faker::Internet.url }

    record do
      { text: }
    end
  end
end
