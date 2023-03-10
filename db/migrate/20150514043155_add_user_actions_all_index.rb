# frozen_string_literal: true

class AddUserActionsAllIndex < ActiveRecord::Migration[4.2]
  def change
    add_index :user_actions,
              %i[user_id created_at action_type],
              name: "idx_user_actions_speed_up_user_all"
  end
end
