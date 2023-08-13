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
class MatchedTerm < ApplicationRecord
  belongs_to :text, inverse_of: :matched_terms
  belongs_to :term, inverse_of: :matched_terms

  validates :matched_text, presence: true, uniqueness: { scope: %i[text_id term_id] }
end
