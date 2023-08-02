# frozen_string_literal: true
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

#
# Seeds the database with the TTRPG topics from the YAML file.
#
module Seeds
  TTRPG_TOPICS = Pathname("#{__dir__}/seed-data/ttrpg-topics.yml").freeze

  def self.seed
    Topic.transaction do
      categories = YAML.load_file(TTRPG_TOPICS, aliases: true).except(".macros")
      topics = categories.values.reduce(&:merge)
      topics.each do |name, attrs|
        topic = TopicBuilder.call(name, attrs.deep_symbolize_keys)
        next unless topic.changed_for_autosave?

        puts TopicChanges.call(topic) # rubocop:disable Rails/Output
        topic.save!
      end
    end
  end
end

Seeds.seed
