# frozen_string_literal: true

class ChangeUserEmailsPrimaryIndex < ActiveRecord::Migration[5.1]
  def up
    remove_index :user_emails, %i[user_id primary]
    add_index :user_emails, %i[user_id primary], unique: true, where: '"primary"'
  end

  def down
    remove_index :user_emails, %i[user_id primary]
    add_index :user_emails, %i[user_id primary], unique: true
  end
end
