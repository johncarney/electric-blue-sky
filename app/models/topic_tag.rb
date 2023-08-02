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
#
# Joins tags to topics.
#
class TopicTag < ApplicationRecord
  belongs_to :topic, inverse_of: :topic_tags
  belongs_to :tag,   inverse_of: :topic_tags

  validates :tag_id, uniqueness: { scope: :topic_id }
end
