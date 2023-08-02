# frozen_string_literal: true

#
# Presents a textual summary of changes to a Topic and it's related terms.
#
class TopicChanges
  include Callable

  attr_reader :topic

  def initialize(topic)
    @topic = topic
  end

  def call
    return [] unless topic.changed_for_autosave?

    [
      "#{change_mode} #{topic.name}...",
      added_terms,
      removed_terms,
      updated_terms_to_ambiguous,
      updated_terms_to_unambiguous,
      added_tags,
      removed_tags
    ].compact
  end

  def change_mode
    if topic.new_record?
      "Creating"
    else
      "Updating"
    end
  end

  def added_terms
    added = topic.terms.select(&:new_record?)
    return unless added.any?

    added_patterns = added.map(&:pattern).sort
    "  Adding #{'term'.pluralize(added.size)}: #{added_patterns.join(', ')}"
  end

  def removed_terms
    removed = topic.terms.select(&:marked_for_destruction?)
    return unless removed.any?

    "  Removing #{'term'.pluralize(removed.size)}: #{removed.map(&:pattern).join(', ')}"
  end

  def updated_terms_to_ambiguous
    updated = topic.terms.reject(&:new_record?).reject(&:marked_for_destruction?)
                .select(&:ambiguous).select(&:ambiguous_changed?)
    return unless updated.any?

    "  Updating #{'term'.pluralize(updated.size)} to ambiguous: #{updated.map(&:pattern).join(', ')}"
  end

  def updated_terms_to_unambiguous
    updated = topic.terms.reject(&:new_record?).reject(&:marked_for_destruction?)
                .reject(&:ambiguous).select(&:ambiguous_changed?)
    return unless updated.any?

    "  Updating #{'term'.pluralize(updated.size)} to unambiguous: #{updated.map(&:pattern).join(', ')}"
  end

  def added_tags
    added = topic.topic_tags.select(&:new_record?).map(&:tag)
    return unless added.any?

    added_names = added.map(&:name).sort
    "  Adding #{'tag'.pluralize(added.size)}: #{added_names.join(', ')}"
  end

  def removed_tags
    removed = topic.topic_tags.select(&:marked_for_destruction?)
    return unless removed.any?

    removed_names = removed.map(&:tag).map(&:name).sort
    "  Removing #{'tag'.pluralize(removed.size)}: #{removed_names.join(', ')}"
  end
end
