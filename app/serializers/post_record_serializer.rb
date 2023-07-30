# frozen_string_literal: true

#
# Sanitizes a post's record for JSON serialization.
#
# Currently the only reason for this is that the skyfall gem uses CBOR::Tagged
# objects with raw binary for the value for image references. These cannot be
# serialized to JSON, so we represent the object as a hash with a base64
# encoded value.
#
# At this point I have no plans for deserializing CBOR::Tagged objects, but I
# do want to store posts as PostgreSQL JSONB records with as much fidelity as
# possible.
#
class PostRecordSerializer
  class << self
    #
    # Returns the sanitized record.
    #
    # @return [Hash] The sanitized record.
    #
    def dump(record)
      serialize(record)
    end

    #
    # This is here to satisfy the interface for an ActiveRecord serializer. It
    # just passes the record straight back.
    #
    # @param [Object] record The record to load.
    #
    # @return [Object] The loaded record
    #
    def load(record)
      record
    end

    private

    #
    # serializes an object.
    #
    # Most objects are returned unaltered. CBOR::Tagged objects are serialized to
    # a hash representation with a base64 encoded value. Arrays and hashes are
    # recursively serialized.
    #
    # @param [Object] object The object to serialize.
    #
    # @return [Object] The serialized object.
    #
    def serialize(object)
      case object
      when Hash
        object.transform_values { |value| serialize(value) }
      when Array
        object.map { |value| serialize(value) }
      when CBOR::Tagged
        serialize_cbor_tagged(object)
      else
        object
      end
    end

    #
    # Returns a hash representation of a CBOR::Tagged object with a
    # base64 encoded value.
    #
    # @param [CBOR::Tagged] cbor_tagged The object to serialize.
    #
    # @return [Hash] A hash representation of the object.
    #
    def serialize_cbor_tagged(cbor_tagged)
      {
        "$type" => "CBOR::Tagged",
        "tag"   => cbor_tagged.tag,
        "value" => Base64.encode64(cbor_tagged.value)
      }
    end
  end
end
