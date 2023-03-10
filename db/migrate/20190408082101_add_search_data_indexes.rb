# frozen_string_literal: true

class AddSearchDataIndexes < ActiveRecord::Migration[5.2]
  def change
    add_index :topic_search_data, %i[topic_id version locale]
    add_index :post_search_data, %i[post_id version locale]
  end
end
