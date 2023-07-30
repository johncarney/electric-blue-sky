# frozen_string_literal: true

# == Schema Information
#
# Table name: posts
#
#  id         :bigint           not null, primary key
#  uri        :string           not null
#  repo       :string           not null
#  record     :jsonb            not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require "rails_helper"

RSpec.describe Post, type: :model do
  it { is_expected.to validate_presence_of(:uri) }
  it { is_expected.to validate_presence_of(:repo) }
end
