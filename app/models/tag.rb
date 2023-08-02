# frozen_string_literal: true

# == Schema Information
#
# Table name: tags
#
#  id         :bigint           not null, primary key
#  name       :citext           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Tag < ApplicationRecord
  has_many :topic_tags, inverse_of: :tag, dependent: :destroy, autosave: true
  has_many :topics, through: :topic_tags

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
