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
FactoryBot.define do
  factory :topic_tag do
    topic
    tag
  end
end
