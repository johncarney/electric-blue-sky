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

  def record_primary_text
    record["text"]
  end

  def record_alt_texts
    Array(record.dig("embed", "images")).pluck("alt") |
      Array(record.dig("embed", "media", "images")).pluck("alt")
  end

  def build_texts_from_record
    build_texts(record_primary_text, text_type: Text::PRIMARY)
    build_texts(*record_alt_texts, text_type: Text::ALT)
  end

  private

  def build_texts(*new_texts, text_type:)
    existing_texts = texts.select { |text| text.text_type == text_type }.pluck(:text)

    (new_texts.compact_blank - existing_texts).map do |text|
      texts.build(text_type:, text:)
    end
  end
end
