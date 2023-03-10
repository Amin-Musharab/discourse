# frozen_string_literal: true

class CreateExpressions < ActiveRecord::Migration[4.2]
  def change
    create_table :expressions, id: false, force: true do |t|
      t.integer :parent_id, null: false
      t.string :parent_type, null: false, limit: 50
      t.integer :expression_type_id, null: false
      t.integer :user_id, null: false
      t.timestamps null: false
    end

    add_index :expressions,
              %i[parent_id parent_type expression_type_id user_id],
              unique: true,
              name: "expressions_pk"
  end
end
