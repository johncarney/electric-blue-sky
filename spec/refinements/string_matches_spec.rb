# frozen_string_literal: true

require "rails_helper"

RSpec.describe StringMatches do
  describe "#matches" do
    using described_class

    subject(:the_matches) { haystack.matches(/\b(#{needles.join("|")})\b/i) }

    let(:needles)  { Faker::Lorem.words(number: 5).uniq }
    let(:haystack) { (Faker::Lorem.words(number: 20).uniq | needles).shuffle.join(" ") }

    it "returns all matches of the pattern in the string" do
      expect(the_matches).to match_array(
        needles.map { |needle| a_match.for(needle).in(haystack) }
      )
    end
  end

  matcher :a_match do
    match do |actual|
      actual.is_a?(MatchData) &&
        matches_needle?
    end

    chain :for do |needle|
      @needle = needle
    end

    chain :in do |haystack|
      @haystack = haystack
    end

    def matches_needle?
      return true unless defined?(@needle)

      actual.to_s.match? @needle
    end

    def matches_haystack?
      return true unless defined?(@haystack)

      actual.start(0) == @haystack.index(actual.to_s)
    end
  end
end
