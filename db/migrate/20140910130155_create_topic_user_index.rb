# frozen_string_literal: true

class CreateTopicUserIndex < ActiveRecord::Migration[4.2]
  def change
    # seems to be the most effective for joining into topics
    add_index :topic_users, %i[user_id topic_id], unique: true
  end
end
