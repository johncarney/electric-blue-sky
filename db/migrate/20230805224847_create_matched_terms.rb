# frozen_string_literal: true

class CreateMatchedTerms < ActiveRecord::Migration[7.0]
  def change
    create_table :matched_terms do |t|
      t.references :text, null: false, foreign_key: true
      t.references :term, null: false, foreign_key: true
      t.string     :matched_text, null: false

      t.timestamps

      t.index %i[text_id term_id matched_text], unique: true
    end
  end
end
