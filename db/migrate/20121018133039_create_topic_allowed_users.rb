# frozen_string_literal: true

class CreateTopicAllowedUsers < ActiveRecord::Migration[4.2]
  def change
    create_table :topic_allowed_users do |t|
      t.integer :user_id, null: false
      t.integer :topic_id, null: false
      t.timestamps null: false
    end

    add_index :topic_allowed_users, %i[topic_id user_id], unique: true
    add_index :topic_allowed_users, %i[user_id topic_id], unique: true
  end
end
