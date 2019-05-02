# frozen_string_literal: true

class AddIsAutoGeneratedToIncomingEmails < ActiveRecord::Migration[4.2]
  def change
    add_column :incoming_emails, :is_auto_generated, :boolean, default: false
  end
end
