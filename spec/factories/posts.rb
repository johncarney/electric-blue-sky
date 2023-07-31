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

    trait :with_image_alt_texts do
      record do
        {
          text:,
          embed: { images: Array.new(2) { { alt: Faker::Lorem.sentence } } }
        }
      end
    end

    trait :with_media_alt_texts do
      record do
        {
          text:,
          embed: { media: { images: Array.new(2) { { alt: Faker::Lorem.sentence } } } }
        }
      end
    end
  end
end
