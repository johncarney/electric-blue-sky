# frozen_string_literal: true

# == Schema Information
#
# Table name: topic_tags
#
#  id         :bigint           not null, primary key
#  topic_id   :bigint           not null
#  tag_id     :bigint           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require "rails_helper"

RSpec.describe TopicTag, type: :model do
  subject(:topic_tag) { create :topic_tag }

  it { is_expected.to belong_to(:topic) }
  it { is_expected.to belong_to(:tag) }
  it { is_expected.to validate_uniqueness_of(:tag_id).scoped_to(:topic_id) }
end
