# frozen_string_literal: true

class AddCategoryIdToUserHistories < ActiveRecord::Migration[4.2]
  def change
    add_column :user_histories, :category_id, :integer
    add_index :user_histories, :category_id
  end
end
