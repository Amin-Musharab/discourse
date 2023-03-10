# frozen_string_literal: true

class AddStylesheetCache < ActiveRecord::Migration[4.2]
  def change
    create_table :stylesheet_cache do |t|
      t.string :target, null: false
      t.string :digest, null: false
      t.text :content, null: false
      t.timestamps null: false
    end

    add_index :stylesheet_cache, %i[target digest], unique: true
  end
end
