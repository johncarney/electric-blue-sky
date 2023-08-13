# frozen_string_literal: true

# == Schema Information
#
# Table name: matched_terms
#
#  id           :bigint           not null, primary key
#  text_id      :bigint           not null
#  term_id      :bigint           not null
#  matched_text :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
FactoryBot.define do
  factory :matched_term do
    text
    term

    matched_text { term.pattern }
  end
end
