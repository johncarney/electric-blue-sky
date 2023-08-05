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

  scope :matching, ->(term) { where("? ~* CONCAT('\\A', pattern, '\\Z')", term) }

  scope :ambiguous,   -> { where(ambiguous: true) }
  scope :unambiguous, -> { where(ambiguous: false) }

  scope :order_by_length, ->(asc_or_desc = :asc) { order(Arel.sql("LENGTH(pattern) #{asc_or_desc.to_s.upcase}")) }

  validates :pattern, presence: true, uniqueness: true

  validate :pattern_is_valid_regex

  def unambiguous?
    !ambiguous?
  end


  private

  def pattern_is_valid_regex
    /#{pattern}/i
  rescue RegexpError => e
    errors.add(:pattern, e.message)
  end
end
