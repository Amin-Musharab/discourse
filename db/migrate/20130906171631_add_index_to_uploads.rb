# frozen_string_literal: true

class AddIndexToUploads < ActiveRecord::Migration[4.2]
  def change
    add_index :uploads, %i[id url]
  end
end
