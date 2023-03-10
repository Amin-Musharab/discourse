# frozen_string_literal: true

class CreateWebCrawlerRequests < ActiveRecord::Migration[5.1]
  def change
    create_table :web_crawler_requests do |t|
      t.date :date, null: false
      t.string :user_agent, null: false
      t.integer :count, null: false, default: 0
    end

    add_index :web_crawler_requests, %i[date user_agent], unique: true
  end
end
