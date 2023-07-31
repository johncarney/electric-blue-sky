# frozen_string_literal: true

class CreateTexts < ActiveRecord::Migration[7.0]
  def change
    create_table :texts do |t|
      t.references :post,      null: false, foreign_key: true
      t.string     :text_type, null: false
      t.text       :text,      null: false, index: { using: :gin, opclass: :gin_trgm_ops }

      t.timestamps
    end
  end
end
