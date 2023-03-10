# frozen_string_literal: true

class AddMultipleAwardToBadges < ActiveRecord::Migration[4.2]
  def change
    add_column :badges, :multiple_grant, :boolean, default: false, null: false

    reversible do |dir|
      dir.up do
        remove_index :user_badges, column: %i[badge_id user_id]
        add_index :user_badges, %i[badge_id user_id]
      end

      dir.down do
        remove_index :user_badges, column: %i[badge_id user_id]
        add_index :user_badges, %i[badge_id user_id], unique: true
      end
    end
  end
end
