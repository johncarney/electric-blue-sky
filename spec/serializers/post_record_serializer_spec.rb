# frozen_string_literal: true

require "rails_helper"

RSpec.describe PostRecordSerializer do
  describe ".dump" do
    subject(:serialized_record) { described_class.dump(record) }

    context "given a simple record" do
      let(:record) do
        {
          "text"      => Faker::Lorem.paragraph,
          "$type"     => "app.bsky.feed.post",
          "langs"     => ["en"],
          "createdAt" => Time.current.iso8601
        }
      end

      it "returns the record unaltered" do
        expect(serialized_record).to eq record
      end
    end

    context "given a record containing a CBOR::Tagged object" do
      let(:record) do
        {
          "text"      => Faker::Lorem.paragraph,
          "$type"     => "app.bsky.feed.post",
          "embed"     => {
            "$type"  => "app.bsky.embed.images",
            "images" => [
              {
                "alt"   => Faker::Lorem.paragraph,
                "image" => {
                  "ref"      => cbor_tagged,
                  "size"     => rand(1000..9999),
                  "$type"    => "blob",
                  "mimeType" => "image/jpeg"
                }
              }
            ]
          },
          "langs"     => ["en"],
          "createdAt" => Time.current.iso8601
        }
      end

      let(:cbor_tagged) { CBOR::Tagged.new(rand(10..99), Faker::Lorem.sentence) }

      it "serializes the CBOR::Tagged object with a base64 encoded value" do # rubocop:todo RSpec/ExampleLength
        expected_record = record.deep_dup
        expected_record.dig("embed", "images", 0, "image")["ref"] = {
          "$type" => "CBOR::Tagged",
          "tag"   => cbor_tagged.tag,
          "value" => Base64.encode64(cbor_tagged.value)
        }
        expect(serialized_record).to eq expected_record
      end
    end
  end

  describe ".load" do
    it "returns the record unaltered" do
      record = instance_double Hash
      expect(described_class.load(record)).to be record
    end
  end
end
