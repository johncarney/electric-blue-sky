# frozen_string_literal: true

#
# Builds or updates a topic and its terms.
#
class TopicBuilder
  include Callable

  attr_reader :name, :attrs

  def initialize(name, attrs)
    @name = name
    @attrs = attrs
  end

  def call
    mark_removed_terms_for_destruction
    update_terms_to_keep
    build_new_terms

    topic
  end

  private

  def topic
    @topic ||= Topic.where(name:).first_or_initialize
  end

  def mark_removed_terms_for_destruction
    removed_terms = topic.terms.reject { |term| term.pattern.in?(patterns.keys) }
    removed_terms.each(&:mark_for_destruction)
  end

  def update_terms_to_keep
    terms_to_keep = topic.terms.select { |term| term.pattern.in?(patterns.keys) }
    terms_to_keep.each do |term|
      term.ambiguous = patterns[term.pattern]
    end
  end

  def build_new_terms
    new_term_patterns = patterns.keys - topic.terms.map(&:pattern)
    patterns.slice(*new_term_patterns).map do |pattern, ambiguous|
      topic.terms.build(pattern:, ambiguous:)
    end
  end

  # Returns a hash of term patterns to booleans indicating whether the pattern
  # is ambiguous or not.
  def patterns
    @patterns ||= begin
      unambiguous_patterns = Array(attrs[:matches]).index_with { false }
      ambiguous_patterns = Array(attrs[:ambiguous_matches]).index_with { true }
      unambiguous_patterns.merge(ambiguous_patterns)
    end
  end
end
