# frozen_string_literal: true

class ChangeTextsTextToCitext < ActiveRecord::Migration[7.0]
  def up
    enable_extension :citext
    change_column :texts, :text, :citext
  end

  def down
    change_column :texts, :text, :text
  end
end
