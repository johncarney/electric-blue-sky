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
  has_many :posts, through: :terms

  has_many :topic_tags, inverse_of: :topic, dependent: :destroy, autosave: true
  has_many :tags, through: :topic_tags

  scope :tagged_with,     ->(*tags) { joins(:tags).where(tags: { name: tags }) }
  scope :not_tagged_with, ->(*tags) { where.not(id: tagged_with(*tags)) }

  scope :meta,     -> { tagged_with("meta") }
  scope :non_meta, -> { not_tagged_with("meta") }

  scope :by_name,         ->(name) { where(name:) }
  scope :by_term,         ->(term) { joins(:terms).merge(Term.matching(term)) }
  scope :by_name_or_term, ->(name_or_term) { joins(:terms).by_name(name_or_term).or(by_term(name_or_term)) }

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  def matching_texts(text_scope: Text.all)
    text_scope.where("text ~* ?", terms.order(Term.length.desc).postgres_pattern)
  end

  def index_texts(text_scope:)
    unambiguous_pattern = /\b(#{Term.unambiguous.order(Term.length.desc).pluck(:pattern).join("|")})\b/i
    # topic_patterns = terms.pluck(Arel.sql("CONCAT('(?<+', terms.id, '>', pattern, ')')"))
    matches = text_scope.map do |text|
      next unless text.text.match?(unambiguous_pattern)

      text.text
      # text.terms << terms.select { |term| text.text =~ term.pattern }
    end.compact_blank
    puts matches.join("\n----------------\n") # rubocop:todo Rails/Output
  end
end
