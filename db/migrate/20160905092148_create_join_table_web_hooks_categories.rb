# frozen_string_literal: true

class CreateJoinTableWebHooksCategories < ActiveRecord::Migration[4.2]
  def change
    create_join_table :web_hooks, :categories
    add_index :categories_web_hooks, %i[web_hook_id category_id], unique: true
  end
end
