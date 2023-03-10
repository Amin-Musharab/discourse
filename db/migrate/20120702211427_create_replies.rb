# frozen_string_literal: true

class CreateReplies < ActiveRecord::Migration[4.2]
  def change
    create_table :post_replies, id: false do |t|
      t.references :post
      t.integer :reply_id
      t.timestamps null: false
    end

    add_index :post_replies, %i[post_id reply_id], unique: true

    execute "INSERT INTO post_replies (post_id, reply_id, created_at, updated_at)
             SELECT p2.id, p.id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
             FROM posts AS p
             INNER JOIN posts AS p2 on p2.post_number = p.reply_to_post_number AND p2.forum_thread_id = P.forum_thread_id
             WHERE p.forum_thread_id IS NOT NULL"
  end
end
