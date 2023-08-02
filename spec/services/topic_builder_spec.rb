# frozen_string_literal: true

require "rails_helper"

RSpec.describe TopicBuilder do
  subject(:seeder) { described_class.new(name, attrs) }

  describe "#call" do
    subject(:seeded_topic) { seeder.call }

    let(:name) { Faker::Game.unique.title }

    let(:attrs) do
      # Looks like Faker's "unique" method doesn't work as expected
      words = Faker::Lorem.unique.words(number: 9).uniq
      {
        matches:           words[0...3],
        ambiguous_matches: words[3...6],
        tags:              words[6...]
      }
    end

    context "when the topic does not exist" do
      it "returns a topic" do
        expect(seeded_topic).to be_a Topic
      end

      it "does not persist the topic" do
        expect(seeded_topic).not_to be_persisted
      end

      it "sets the topic's name" do
        expect(seeded_topic).to have_attributes(name:)
      end

      it "builds the topic's terms" do
        term_patterns = seeded_topic.terms.map(&:pattern)
        expect(term_patterns).to match_array(attrs[:matches] + attrs[:ambiguous_matches])
      end

      it "does not persist the topic's terms" do
        expect(seeded_topic.terms).not_to be_any(&:persisted?)
      end

      it %(does not mark unambiguous matches as "ambiguous") do
        unambiguous_terms = seeded_topic.terms.reject(&:ambiguous?)
        expect(unambiguous_terms.map(&:pattern)).to match_array attrs[:matches]
      end

      it %(marks ambiguous matches as "ambiguous") do
        ambiguous_terms = seeded_topic.terms.select(&:ambiguous?)
        expect(ambiguous_terms.map(&:pattern)).to match_array attrs[:ambiguous_matches]
      end

      it "builds the topic's tags" do
        tag_names = seeded_topic.topic_tags.map(&:tag).map(&:name)
        expect(tag_names).to match_array(attrs[:tags])
      end

      it "does not persist the topic's tags" do
        seeded_tags = seeded_topic.topic_tags.map(&:tag)
        expect(seeded_tags).not_to be_any(&:persisted?)
      end
    end

    context "when the topic does exist" do
      let(:topic) { create :topic, name: }

      before do
        topic.save!
      end

      it "returns the existing topic" do
        expect(seeded_topic).to eq topic
      end

      context "when one of the topic's terms already exists" do
        let(:existing_term) do
          build :unambiguous_term, topic:, pattern: attrs[:matches].sample
        end

        before do
          existing_term.save!
        end

        it "uses the existing term" do
          expect(seeded_topic.terms).to include existing_term
        end
      end

      context %(when an existing ambiguous term is now listed as an unambiguous match) do
        let(:existing_term) do
          build :ambiguous_term, topic:, pattern: attrs[:matches].sample
        end

        before do
          existing_term.save!
        end

        it "uses the existing term" do
          expect(seeded_topic.terms).to include existing_term
        end

        it "changes the existing term to ambiguous" do
          seeded_term = seeded_topic.terms.find { |t| t.pattern == existing_term.pattern }
          expect(seeded_term.changed_attributes).to include("ambiguous" => true)
        end
      end

      context %(when an existing unambiguous term is now listed as an ambiguous match) do
        let(:existing_term) do
          build :unambiguous_term, topic:, pattern: attrs[:ambiguous_matches].sample
        end

        before do
          existing_term.save!
        end

        it "uses the existing term" do
          expect(seeded_topic.terms).to include(existing_term)
        end

        it "changes the existing term to unambiguous" do
          seeded_term = seeded_topic.terms.find { |t| t.pattern == existing_term.pattern }
          expect(seeded_term.changed_attributes).to include("ambiguous" => false)
        end
      end

      context "when a term is removed" do
        let(:removed_term) do
          create :unambiguous_term, topic:, pattern: attrs[:matches].sample
        end

        before do
          topic.terms << removed_term
          attrs[:matches].delete(removed_term.pattern)
        end

        it "marks the term for destruction" do
          term = seeded_topic.terms.find { |t| t.pattern == removed_term.pattern }
          expect(term).to be_marked_for_destruction
        end
      end

      context "when one of the topic's tags already exists, but not associated with the topic" do
        let(:existing_tag) { build :tag, name: attrs[:tags].sample }

        before do
          existing_tag.save!
        end

        it "adds the existing tag to the topic" do
          topic_tag = seeded_topic.topic_tags.find { |tt| tt.tag.name == existing_tag.name }
          expect(topic_tag.tag).to eq existing_tag
        end
      end

      context "when one of the topic's tags already exists and is associated with the topic" do
        let(:existing_tag) { build :tag, name: attrs[:tags].sample }

        before do
          existing_tag.save!
          topic.tags << existing_tag
        end

        it "uses the existing association" do
          topic_tag = seeded_topic.topic_tags.find { |tt| tt.tag.name == existing_tag.name }
          expect(topic_tag).not_to be_changed
        end
      end

      context "when one of the topic's tags is removed" do
        let(:existing_tag) { build :tag, name: attrs[:tags].sample }

        before do
          existing_tag.save!
          topic.tags << existing_tag
          attrs[:tags].delete(existing_tag.name)
        end

        it "marks the association for destruction" do
          topic_tag = seeded_topic.topic_tags.find { |tt| tt.tag.name == existing_tag.name }
          expect(topic_tag).to be_marked_for_destruction
        end
      end
    end
  end
end
