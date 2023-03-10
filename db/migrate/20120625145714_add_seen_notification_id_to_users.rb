# frozen_string_literal: true

class AddSeenNotificationIdToUsers < ActiveRecord::Migration[4.2]
  def change
    execute "TRUNCATE TABLE notifications"

    add_column :users, :seen_notificaiton_id, :integer, default: 0, null: false
    add_column :notifications, :forum_thread_id, :integer, null: true
    add_column :notifications, :post_number, :integer, null: true
  end
end
