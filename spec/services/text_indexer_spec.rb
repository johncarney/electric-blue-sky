# frozen_string_literal: true

require "rails_helper"

RSpec.describe TextIndexer do
  subject(:indexer) { described_class.new(text) }

  describe "#call" do
    let(:text) { build :text, text: contents }

    let(:terms) do
      topic = create :topic
      Faker::Lorem.words(number: 5).uniq.map do |word|
        build :term, topic:, pattern: word
      end
    end

    before do
      terms.shuffle.each(&:save!)
    end

    context "when some terms are matched" do
      let(:matching_terms) { terms.sample(2) }

      let(:contents) do
        ((Faker::Lorem.words(number: 30).uniq - terms.map(&:pattern)) | matching_terms.map(&:pattern)).join(" ")
      end

      it "builds a matched term for each match" do
        indexer.call
        expect(text.matched_terms).to match_array(
          matching_terms.map { |term| a_matched_term.for(term).on(term.pattern) }
        )
      end
    end

    context "when no terms are matched" do
      let(:contents) do
        (Faker::Lorem.words(number: 30).uniq - terms.map(&:pattern)).join(" ")
      end

      it "does not build any matched terms" do
        indexer.call
        expect(text.matched_terms).to be_empty
      end
    end

    context "when a term is already associated with the text with the same match" do
      let(:contents) { associated_term.pattern }

      let(:associated_term) { terms.sample }

      before do
        text.matched_terms.build(term_id: associated_term.id, matched_text: associated_term.pattern)
      end

      it "does not build a new matched term" do
        indexer.call
        expect(text.matched_terms).to contain_exactly(
          a_matched_term.for(associated_term).on(associated_term.pattern)
        )
      end
    end

    context "when a term is matched multiple times" do
      let(:terms) { build_list :term, 1, pattern: "a{1,2}" }

      context "with identical matching text" do
        let(:contents) { "aa aa" }

        it "only builds a single matched term" do
          indexer.call
          expect(text.matched_terms).to contain_exactly(
            a_matched_term.for(terms.first).on("aa")
          )
        end
      end

      context "with different matching text" do
        let(:contents) { "a aa" }

        it "builds a matched term for each match" do
          indexer.call
          expect(text.matched_terms).to match_array(
            %w[a aa].map { |matched_text| a_matched_term.for(terms.first).on(matched_text) }
          )
        end
      end
    end

    context "given a term scope" do
      subject(:indexer) { described_class.new(text, term_scope:) }

      let(:contents) do
        (Faker::Lorem.words(number: 30).uniq | terms.map(&:pattern)).join(" ")
      end

      let(:term_scope) do
        Term.where(id: terms.sample(2).map(&:id))
      end

      it "only builds matched terms for terms in the given scope" do
        indexer.call
        expect(text.matched_terms).to match_array(
          term_scope.map { |term| a_matched_term.for(term).on(term.pattern) }
        )
      end
    end
  end

  matcher :a_matched_term do
    match do |actual|
      actual.is_a?(MatchedTerm) &&
        matches_term? &&
        matches_text?
    end

    chain :for do |term|
      @term = term
    end

    chain :on do |text|
      @text = text
    end

    def matches_term?
      return true unless defined?(@term)

      actual.term == @term
    end

    def matches_text?
      return true unless defined?(@text)

      actual.matched_text == @text
    end
  end
end
