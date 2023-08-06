# frozen_string_literal: true

class TextIndexer
  include Callable

  using StringMatches

  attr_reader :text, :term_scope

  def initialize(text, term_scope: Term.all)
    @text = text
    @term_scope = term_scope
  end

  def call
    (matches_attrs - current_matched_terms_attrs).each do |match_attrs|
      text.matched_terms.build(match_attrs)
    end
  end

  private

  def current_matched_terms_attrs
    text.matched_terms.map { |match| match.slice("term_id", "matched_text") }
  end

  def matches_attrs
    matches.map do |match|
      {
        "term_id"      => match.named_captures.compact.keys.first.to_i,
        "matched_text" => match.to_s
      }
    end.uniq
  end

  def matches
    text.text.matches(pattern)
  end

  def pattern
    /\b(#{term_scope.grouped_patterns.join("|")})\b/i
  end
end
