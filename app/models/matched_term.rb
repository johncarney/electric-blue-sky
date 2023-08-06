# frozen_string_literal: true

class MatchedTerm < ApplicationRecord
  belongs_to :text, inverse_of: :matched_terms
  belongs_to :term, inverse_of: :matched_terms

  validates :matched_text, presence: true, uniqueness: { scope: %i[text_id term_id] }
end
