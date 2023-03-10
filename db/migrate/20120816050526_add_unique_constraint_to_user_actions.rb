# frozen_string_literal: true

class AddUniqueConstraintToUserActions < ActiveRecord::Migration[4.2]
  def change
    add_index :user_actions,
              %w[action_type user_id target_forum_thread_id target_post_id acting_user_id],
              name: "idx_unique_rows",
              unique: true
  end
end
