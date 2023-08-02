# frozen_string_literal: true

class MakeTermPatternGloballyUnique < ActiveRecord::Migration[7.0]
  def change
    add_index :terms, :pattern, unique: true
    remove_index :terms, %i[topic_id pattern], unique: true
  end
end
