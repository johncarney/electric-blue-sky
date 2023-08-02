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

  has_many :topic_tags, inverse_of: :topic, dependent: :destroy, autosave: true
  has_many :tags, through: :topic_tags

  scope :tagged_with,     ->(*tags) { joins(:tags).where(tags: { name: tags }) }
  scope :not_tagged_with, ->(*tags) { where.not(id: tagged_with(*tags)) }

  scope :by_name,         ->(name) { where(name:) }
  scope :by_term,         ->(term) { joins(:terms).merge(Term.matching(term)) }
  scope :by_name_or_term, ->(name_or_term) { joins(:terms).by_name(name_or_term).or(by_term(name_or_term)) }

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
