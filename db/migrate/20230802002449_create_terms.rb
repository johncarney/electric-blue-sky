# frozen_string_literal: true

class CreateTerms < ActiveRecord::Migration[7.0]
  def change
    create_table :terms do |t|
      t.references :topic,     null: false, foreign_key: true
      t.string     :pattern,   null: false
      t.boolean    :ambiguous, null: false, default: false

      t.timestamps

      t.index %i[topic_id pattern], unique: true
    end
  end
end
