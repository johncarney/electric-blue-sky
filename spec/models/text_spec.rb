# frozen_string_literal: true

# == Schema Information
#
# Table name: texts
#
#  id         :bigint           not null, primary key
#  post_id    :bigint           not null
#  type       :string           not null
#  text       :text             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require "rails_helper"

RSpec.describe Text, type: :model do
  it { is_expected.to validate_presence_of(:text_type) }
  it { is_expected.to validate_presence_of(:text) }
  it { is_expected.to validate_inclusion_of(:text_type).in_array(Text::TYPES) }
end
