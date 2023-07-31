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

  describe "#build_texts_from_record" do
    context "given a post with primary text" do
      subject(:post) { build(:post) }

      it "adds the primary text to the post" do
        post.build_texts_from_record
        expect(post.texts.select(&:primary?).map(&:text)).to contain_exactly(post.record["text"])
      end

      context "when the primary text already exists on the post" do
        before do
          post.texts.build(text_type: Text::PRIMARY, text: post.record["text"])
        end

        it "does not add an additional primary text to the post" do
          post.build_texts_from_record
          expect(post.texts.select(&:primary?).map(&:text)).to contain_exactly(post.record["text"])
        end
      end
    end

    context "given a post with image alt-texts" do
      subject(:post) { build(:post, :with_image_alt_texts) }

      it "adds the image alt-texts to the post" do
        expected_alt_texts = post.record.dig("embed", "images").pluck("alt")
        post.build_texts_from_record
        expect(post.texts.select(&:alt?).map(&:text)).to match_array expected_alt_texts
      end

      context "when an alt-text is blank" do
        before do
          post.record.dig("embed", "images", rand(2))["alt"] = [nil, "", " "].sample
        end

        it "does not include the blank alt-text" do
          expected_alt_texts = post.record.dig("embed", "images").pluck("alt").compact_blank
          post.build_texts_from_record
          expect(post.texts.select(&:alt?).map(&:text)).to match_array expected_alt_texts
        end
      end

      context "when an alt-text already exists on the post" do
        before do
          text = post.record.dig("embed", "images").pluck("alt").sample
          post.texts.build(text_type: Text::ALT, text:)
        end

        it "does not duplicate existing alt-texts" do
          expected_alt_texts = post.record.dig("embed", "images").pluck("alt")
          post.build_texts_from_record
          expect(post.texts.select(&:alt?).map(&:text)).to match_array expected_alt_texts
        end
      end
    end

    context "given a post with media alt-texts" do
      subject(:post) { build(:post, :with_media_alt_texts) }

      it "adds the media alt-texts to the post" do
        expected_alt_texts = post.record.dig("embed", "media", "images").pluck("alt")
        post.build_texts_from_record
        expect(post.texts.select(&:alt?).map(&:text)).to match_array expected_alt_texts
      end

      context "when an alt-text is blank" do
        before do
          post.record.dig("embed", "media", "images", rand(2))["alt"] = [nil, "", " "].sample
        end

        it "does not include the blank alt-text" do
          expected_alt_texts = post.record.dig("embed", "media", "images").pluck("alt").compact_blank
          post.build_texts_from_record
          expect(post.texts.select(&:alt?).map(&:text)).to match_array expected_alt_texts
        end
      end

      context "when an alt-text already exists on the post" do
        before do
          text = post.record.dig("embed", "media", "images").pluck("alt").sample
          post.texts.build(text_type: Text::ALT, text:)
        end

        it "does not duplicate existing alt-texts" do
          expected_alt_texts = post.record.dig("embed", "media", "images").pluck("alt")
          post.build_texts_from_record
          expect(post.texts.select(&:alt?).map(&:text)).to match_array expected_alt_texts
        end
      end
    end

    context "when alt-text is duplicated in the post" do
      subject(:post) do
        build(
          :post,
          record: {
            text:  Faker::Lorem.paragraph,
            embed: {
              images: [{ alt: duplicate_alt_text }, { alt: duplicate_alt_text }],
              media:  { images: [{ alt: duplicate_alt_text }] }
            }
          }
        )
      end

      let(:duplicate_alt_text) { Faker::Lorem.sentence }

      it "does not include duplicate alt-texts" do
        post.build_texts_from_record
        expect(post.texts.select(&:alt?).map(&:text)).to contain_exactly duplicate_alt_text
      end
    end
  end
end
