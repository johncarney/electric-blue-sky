# frozen_string_literal: true

# == Schema Information
#
# Table name: posts
#
#  id         :bigint           not null, primary key
#  uri        :string           not null
#  repo       :string           not null
#  record     :jsonb            not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
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
