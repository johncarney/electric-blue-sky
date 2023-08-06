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

#
# Post text.
#
class Text < ApplicationRecord
  PRIMARY = "primary"
  ALT     = "alt"
  TYPES   = [PRIMARY, ALT].freeze

  belongs_to :post, inverse_of: :texts

  has_many :matched_terms, inverse_of: :text, dependent: :delete_all, autosave: true
  has_many :terms, through: :matched_terms

  scope :primary, -> { where(text_type: PRIMARY) }
  scope :alt,     -> { where(text_type: ALT) }

  validates :text_type, :text, presence: true
  validates :text_type, inclusion: { in: TYPES }

  def primary?
    text_type == PRIMARY
  end

  def alt?
    text_type == ALT
  end
end
