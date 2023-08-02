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
require "rails_helper"

RSpec.describe Topic, type: :model do
  subject(:topic) { build(:topic) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name).case_insensitive }

  describe ".tagged_with" do
    subject(:topics) { described_class.tagged_with(tag.name) }

    let(:tag) { create :tag }

    let(:tagged_topics)   { build_list :topic, 2, tags: [tag] }
    let(:untagged_topics) { build_list :topic, 2, tags: create_list(:tag, 1) }

    before do
      [tagged_topics, untagged_topics].flatten.shuffle.each(&:save!)
    end

    it "returns topics tagged with the given tag name" do
      expect(topics).to match_array(tagged_topics)
    end
  end

  describe ".not_tagged_with" do
    subject(:topics) { described_class.not_tagged_with(tag.name) }

    let(:tag) { create :tag }

    let(:tagged_topics)   { build_list :topic, 2, tags: [tag] }
    let(:untagged_topics) { build_list :topic, 2, tags: create_list(:tag, 1) }

    before do
      [tagged_topics, untagged_topics].flatten.shuffle.each(&:save!)
    end

    it "returns topics not tagged with the given tag name" do
      expect(topics).to match_array(untagged_topics)
    end
  end

  describe ".by_name" do
    subject(:matching_topics) { described_class.by_name(matching_topic.name) }

    let(:matching_topic) { topics.sample }

    let(:topics) { build_list :topic, 3 }

    before do
      topics.shuffle.each(&:save!)
    end

    it "returns topics with the given name" do
      expect(matching_topics).to contain_exactly(matching_topic)
    end
  end

  describe ".by_term" do
    subject(:matching_topics) { described_class.by_term("bcd") }

    let(:matches) do
      %w[b*cd bcd*].map do |pattern|
        build :topic, terms: [build(:term, pattern:)]
      end
    end

    let(:not_match) { build :topic, terms: build_list(:term, 1, pattern: "xyz") }

    before do
      [*matches, not_match].shuffle.each(&:save!)
    end

    it "returns topics with terms matching the given term" do
      expect(matching_topics).to match_array(matches)
    end

    it "only includes topics with terms matching at the start of the given string" do
      topic = create(:topic, terms: create_list(:term, 1, pattern: "abcd"))
      matching_topics = described_class.by_term("abcd")
      expect(matching_topics).to contain_exactly topic
    end

    it "only includes topics with terms matching at the end of the given string" do
      topic = create(:topic, terms: create_list(:term, 1, pattern: "bcde"))
      matching_topics = described_class.by_term("bcde")
      expect(matching_topics).to contain_exactly topic
    end
  end

  describe ".by_name_or_term" do
    let(:matches)   { build_list :topic, 1, terms: create_list(:term, 1) }
    let(:not_match) { build :topic, terms: create_list(:term, 1) }

    before do
      [*matches, not_match].shuffle.each(&:save!)
    end

    context "given a name" do
      subject(:matching_topics) { described_class.by_name_or_term(matches.first.name) }

      it "returns topics with the given name" do
        expect(matching_topics).to contain_exactly(matches.first)
      end
    end

    context "given a term" do
      subject(:matching_topics) { described_class.by_name_or_term(matches.first.terms.sample.pattern) }

      it "returns topics with terms matching the given string" do
        expect(matching_topics).to contain_exactly(matches.first)
      end
    end

    context "when a topic has a name matching the given term and another topic has a matching term" do
      subject(:matching_topics) { described_class.by_name_or_term(matches.first.name) }

      let(:matches) do
        topic = build :topic, terms: create_list(:term, 1)
        [topic, build(:topic, terms: create_list(:term, 1, pattern: topic.name))]
      end

      it "returns both topics" do
        expect(matching_topics).to match_array(matches)
      end
    end
  end
end
