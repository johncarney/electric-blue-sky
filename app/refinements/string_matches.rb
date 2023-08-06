# frozen_string_literal: true

module StringMatches
  refine String do
    def matches(pattern, offset: nil)
      next_match = match(pattern, *offset)
      return [] unless next_match

      [next_match, *matches(pattern, offset: next_match.end(0))]
    end
  end
end
