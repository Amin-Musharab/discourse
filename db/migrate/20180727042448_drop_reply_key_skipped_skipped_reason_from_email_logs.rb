# frozen_string_literal: true

class DropReplyKeySkippedSkippedReasonFromEmailLogs < ActiveRecord::Migration[5.2]
  def up
    remove_index :email_logs, %i[skipped bounced created_at]
    remove_index :email_logs, name: "idx_email_logs_user_created_filtered"
    add_index :email_logs, %i[user_id created_at]
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
