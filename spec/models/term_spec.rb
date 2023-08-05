# frozen_string_literal: true

# == Schema Information
#
# Table name: terms
#
#  id         :bigint           not null, primary key
#  topic_id   :bigint           not null
#  pattern    :string           not null
#  ambiguous  :boolean          default(FALSE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require "rails_helper"

RSpec.describe Term, type: :model do
  subject(:term) { create :term }

  it { is_expected.to belong_to(:topic).inverse_of(:terms) }
  it { is_expected.to validate_presence_of(:pattern) }
  it { is_expected.to validate_uniqueness_of(:pattern) }

  it "validates that :pattern is a valid regular expression", :aggregate_failures do
    expect(build(:term, pattern: "[")).not_to be_valid
    expect(build(:term, pattern: "[a-z]")).to be_valid
  end

  context "when ambiguous is true" do
    subject(:term) { create :term, ambiguous: true }

    it { is_expected.to be_ambiguous }
    it { is_expected.not_to be_unambiguous }
  end

  context "when ambiguous is false" do
    subject(:term) { create :term, ambiguous: false }

    it { is_expected.to be_unambiguous }
    it { is_expected.not_to be_ambiguous }
  end

  describe ".matching" do
    subject(:matching_terms) { described_class.matching(term) }

    let(:term) { "abc" }

    let(:terms) do
      topic = create :topic
      %w[ab*c cba ab+c abbc].map { |pattern| build :term, topic:, pattern: }
    end

    before do
      terms.shuffle.each(&:save!)
    end

    it "returns terms with patterns matching the given string" do
      expect(matching_terms).to contain_exactly(terms[0], terms[2])
    end
  end

  describe ".ambiguous" do
    subject(:ambiguous_terms) { described_class.ambiguous }

    let(:terms) do
      topic = create :topic
      %i[ambiguous unambiguous].flat_map { |trait| build_list :term, 2, trait, topic: }
    end

    it "returns only ambiguous terms" do
      terms.shuffle.each(&:save!)
      expect(ambiguous_terms).to match_array terms.select(&:ambiguous?)
    end
  end

  describe ".unambiguous" do
    subject(:unambiguous_terms) { described_class.unambiguous }

    let(:terms) do
      topic = create :topic
      %i[ambiguous unambiguous].flat_map { |trait| build_list :term, 2, trait, topic: }
    end

    it "returns only unambiguous terms" do
      terms.shuffle.each(&:save!)
      expect(unambiguous_terms).to match_array terms.select(&:unambiguous?)
    end
  end

  describe ".grouped_patterns" do
    subject(:grouped_patterns) { described_class.grouped_patterns }

    let(:patterns) { Faker::Lorem.unique.words(number: 3) }

    let(:terms) do
      topic = create :topic
      patterns.map { |pattern| build :term, topic:, pattern: }
    end

    before do
      terms.shuffle.each(&:save!)
    end

    matcher :be_valid_regex do
      match do |actual|
        /#{actual}/i
      rescue RegexpError => e
        @exception = e
        false
      end

      failure_message do |actual|
        "expected #{actual} to be a valid regular expression, but got #{@exception}"
      end
    end

    it "returns valid regular expressions" do
      expect(grouped_patterns).to all be_valid_regex
    end

    it "returns regular expressions enclosed in groups named by each term's id" do
      expected_patterns = terms.map { |term| "(?<+#{term.id}>#{term.pattern})" }
      expect(grouped_patterns).to match_array expected_patterns
    end
  end

  describe ".postgres_pattern" do
    subject(:postgres_pattern) { term_scope.postgres_pattern }

    let(:term_scope) { described_class.order(described_class.length.desc, described_class[:pattern].asc) }

    let(:patterns) { Faker::Lorem.unique.words(number: 3) }

    let(:terms) do
      topic = create :topic
      patterns.map { |pattern| build :term, topic:, pattern: }
    end

    before do
      terms.shuffle.each(&:save!)
    end

    it "returns a PostgreSQL-compatible regular expression combining all terms" do
      expected_pattern = ['\m(', *term_scope.pluck(:pattern).join("|"), ')\M'].join
      expect(postgres_pattern).to eq expected_pattern
    end
  end
end
