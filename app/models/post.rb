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

#
# A Bluesky post
#
class Post < ApplicationRecord
  has_many :texts, inverse_of: :post, dependent: :destroy, autosave: true

  serialize :record, PostRecordSerializer

  validates :uri, :repo, presence: true
end
