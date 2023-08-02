# frozen_string_literal: true

class CreateTopics < ActiveRecord::Migration[7.0]
  def change
    create_table :topics do |t|
      t.citext :name, null: false, index: { unique: true }

      t.timestamps
    end
  end
end
