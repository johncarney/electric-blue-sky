# frozen_string_literal: true

require "rails_helper"

RSpec.describe MatchedTerm, type: :model do
  subject(:matched_term) { create :matched_term }

  it { is_expected.to belong_to(:text).inverse_of(:matched_terms) }
  it { is_expected.to belong_to(:term).inverse_of(:matched_terms) }

  it { is_expected.to validate_presence_of(:matched_text) }
  it { is_expected.to validate_uniqueness_of(:matched_text).scoped_to(%i[text_id term_id]) }
end
