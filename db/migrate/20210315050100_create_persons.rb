# frozen_string_literal: true

class CreatePersons < ActiveRecord::Migration[6.1]
  def change
    create_table :persons do |t|
      t.string :last_name
      t.string :first_name
      t.string :middle_name
      t.integer :sex_id
      t.date :birthdate
      t.date :deathdate
    end
  end
end
