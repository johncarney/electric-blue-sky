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
class Term < ApplicationRecord
  belongs_to :topic, inverse_of: :terms

  has_many :matched_terms, inverse_of: :term, dependent: :delete_all, autosave: true
  has_many :texts, through: :matched_terms
  has_many :posts, through: :texts

  scope :matching, lambda { |term|
    regexp = ArelTools.concat('\A', arel_table[:pattern], '\Z')
    where(ArelTools.quoted(term).matches_regexp(regexp, false))
  }

  scope :ambiguous,   -> { where(ambiguous: true) }
  scope :unambiguous, -> { where(ambiguous: false) }

  validates :pattern, presence: true, uniqueness: true

  validate :pattern_is_valid_regex

  def unambiguous?
    !ambiguous?
  end

  class << self
    def grouped_patterns
      pattern = arel_table[:pattern]
      order(ArelTools.length(pattern).desc, pattern.asc)
        .pluck(ArelTools.concat("(?<+", arel_table[:id], ">", pattern, ")"))
    end

    def postgres_pattern
      pattern = arel_table[:pattern]
      terms_patterns = order(ArelTools.length(pattern).desc, pattern.asc)
      ['\m(', terms_patterns.pluck(:pattern).join("|"), ')\M'].join
    end

    def length
      ArelTools.length(arel_table[:pattern])
    end
  end

  private

  def pattern_is_valid_regex
    /#{pattern}/i
  rescue RegexpError => e
    errors.add(:pattern, e.message)
  end
end
