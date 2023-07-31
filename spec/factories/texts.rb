# frozen_string_literal: true

# == Schema Information
#
# Table name: texts
#
#  id         :bigint           not null, primary key
#  post_id    :bigint           not null
#  text_type  :string           not null
#  text       :citext           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :text do
    post
    text_type { Text::TYPES.sample }
    text      { Faker::Lorem.paragraph }

    trait :primary do
      text_type { Text::PRIMARY }
    end

    trait :alt do
      text_type { Text::ALT }
    end

    factory :primary_text, traits: [:primary]
    factory :alt_text,     traits: [:alt]
  end
end
