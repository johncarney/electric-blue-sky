# frozen_string_literal: true

# == Schema Information
#
# Table name: terms
#
#  id         :bigint           not null, primary key
#  topic_id   :bigint           not null
#  pattern    :string           not null
#  ambiguous  :boolean          default(FALSE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :term do
    topic

    pattern   { Faker::Lorem.unique.word }
    ambiguous { [true, false].sample }

    trait :ambiguous do
      ambiguous { true }
    end

    trait :unambiguous do
      ambiguous { false }
    end

    factory :ambiguous_term,   traits: %i[ambiguous]
    factory :unambiguous_term, traits: %i[unambiguous]
  end
end
