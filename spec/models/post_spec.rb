# frozen_string_literal: true

require "rails_helper"

RSpec.describe Post, type: :model do
  it { is_expected.to validate_presence_of(:uri) }
  it { is_expected.to validate_presence_of(:repo) }
end
