# frozen_string_literal: true

require "rails_helper"

RSpec.describe TopicChanges do
  subject(:changes) { described_class.new(topic) }

  describe "#call" do
    subject(:change_messages) { changes.call }

    let(:topic) do
      topic = build :topic, name: topic_name
      attrs[:matches].each { |pattern| topic.terms.build(pattern:, ambiguous: false) }
      attrs[:ambiguous_matches].each { |pattern| topic.terms.build(pattern:, ambiguous: true) }
      topic
    end

    let(:topic_name) { Faker::Game.unique.title }

    let(:attrs) do
      # Looks like Faker's "unique" method doesn't work as expected
      words = Faker::Lorem.unique.words(number: 6).uniq
      {
        matches:           words[0...3],
        ambiguous_matches: words[3...]
      }
    end

    context "when the topic has not changed" do
      before do
        topic.save!
      end

      it { is_expected.to eq([]) }
    end

    context "when the topic is new" do
      it { is_expected.to include("Creating #{topic_name}...") }

      it "includes the added terms" do
        added_terms = attrs.values.flatten.sort
        expect(change_messages).to include("  Adding #{'term'.pluralize(added_terms.size)}: #{added_terms.join(', ')}")
      end
    end

    context "when the topic exists" do
      before do
        topic.save!
      end

      it "includes added terms" do
        topic.terms.build(pattern: "added term")
        expect(change_messages).to include("  Adding term: added term")
      end

      it "includes removed terms" do
        removed_term = topic.terms.sample
        removed_term.mark_for_destruction
        expect(change_messages).to include("  Removing term: #{removed_term.pattern}")
      end

      it "includes terms updated to ambiguous" do
        changed_term = topic.terms.reject(&:ambiguous).sample
        changed_term.ambiguous = true
        expect(change_messages).to include("  Updating term to ambiguous: #{changed_term.pattern}")
      end

      it "includes terms updated to unambiguous" do
        changed_term = topic.terms.select(&:ambiguous).sample
        changed_term.ambiguous = false
        expect(change_messages).to include("  Updating term to unambiguous: #{changed_term.pattern}")
      end
    end
  end
end
