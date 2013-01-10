# -*- encoding : utf-8 -*-
class CreateGroups < ActiveRecord::Migration
  def self.up
    create_table :groups do |t|
      t.integer :speciality_id
      
      t.string :name
      t.integer :forming_year
      
      t.timestamps
    end
  end

  def self.down
    drop_table :groups
  end
end
