# frozen_string_literal: true

# == Schema Information
#
# Table name: topics
#
#  id         :bigint           not null, primary key
#  name       :citext           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Topic < ApplicationRecord
  has_many :terms, inverse_of: :topic, dependent: :destroy, autosave: true

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
