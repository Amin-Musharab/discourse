# frozen_string_literal: true

class AddIndexMethodEnabledOnUserSecondFactors < ActiveRecord::Migration[5.2]
  def change
    add_index :user_second_factors, %i[method enabled]
  end
end
