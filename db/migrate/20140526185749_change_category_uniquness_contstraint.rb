# frozen_string_literal: true

class ChangeCategoryUniqunessContstraint < ActiveRecord::Migration[4.2]
  def change
    remove_index :categories, name: "index_categories_on_name"
    add_index :categories, %i[parent_category_id name], unique: true
  end
end
