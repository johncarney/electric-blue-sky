# frozen_string_literal: true

FactoryBot.define do
  factory :matched_term do
    text
    term

    matched_text { term.pattern }
  end
end
