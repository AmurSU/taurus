# -*- encoding : utf-8 -*-
class CreateLessonTypes < ActiveRecord::Migration
  def self.up
    create_table :lesson_types do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :lesson_types
  end
end
