# frozen_string_literal: true

class CreateVersions < ActiveRecord::Migration[6.1]
  def change
    create_table :versions do |t|
      t.string :model
      t.integer :model_id
      t.json :changes
      t.timestamps null: false
    end
  end
end
