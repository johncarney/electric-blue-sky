# frozen_string_literal: true

class CreatePosts < ActiveRecord::Migration[7.0]
  def change
    reversible do |dir|
      dir.up { enable_extension :pg_trgm }
    end

    create_table :posts do |t|
      t.string :uri,    null: false, index: { unique: true }
      t.string :repo,   null: false, index: true
      t.jsonb  :record, null: false, default: {}, index: { using: :gin, opclass: :jsonb_path_ops }

      t.timestamps

      # t.index "((record ->> 'text')) gin_trgm_ops", name: :index_posts_on_record_text, using: :gin
    end
  end
end
