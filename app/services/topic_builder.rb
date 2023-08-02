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
    mark_removed_tags_for_destruction
    build_new_tags

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

  def mark_removed_tags_for_destruction
    removed_topic_tags = topic.topic_tags.reject { |topic_tag| topic_tag.tag.name.in?(tag_names) }
    removed_topic_tags.each(&:mark_for_destruction)
  end

  def build_new_tags
    new_tag_names = tag_names - topic.tags.map(&:name)
    new_tag_names.each { |name| topic.topic_tags.build(tag: Tag.where(name:).first_or_initialize) }
  end

  def tag_names
    @tag_names ||= Array(attrs[:tags]).flat_map { |tags| tags.split(/\s*,\s*/) }.uniq
  end

  # Returns a hash of term patterns to booleans indicating whether the pattern
  # is ambiguous or not.
  def patterns
    @patterns ||= begin
      unambiguous_patterns = fold_patterns(attrs[:matches]).index_with { false }
      ambiguous_patterns = fold_patterns(attrs[:ambiguous_matches]).index_with { true }
      unambiguous_patterns.merge(ambiguous_patterns)
    end
  end

  def fold_patterns(patterns)
    Array(patterns).map { |pattern| Array(pattern).join }
  end
end
