# frozen_string_literal: true

class AddIndexTopicIdSortOrderOnPosts < ActiveRecord::Migration[5.2]
  def change
    add_index :posts, %i[topic_id sort_order], order: { sort_order: :asc }
  end
end
