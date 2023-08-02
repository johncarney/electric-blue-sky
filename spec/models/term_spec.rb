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
  it { is_expected.to validate_uniqueness_of(:pattern).scoped_to(:topic_id) }

  it "validates that :pattern is a valid regular expression", :aggregate_failures do
    expect(build(:term, pattern: "[")).not_to be_valid
    expect(build(:term, pattern: "[a-z]")).to be_valid
  end
end
