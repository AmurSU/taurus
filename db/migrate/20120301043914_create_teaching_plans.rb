class CreateTeachingPlans < ActiveRecord::Migration
  def self.up
    create_table :teaching_plans do |t|
      t.references :speciality, :null => false
      t.references :discipline, :null => false
      t.integer :course, :null => false
      t.integer :semester, :null => false
      t.integer :lections
      t.integer :practics
      t.integer :lab_works
      t.boolean :exam, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :teaching_plans
  end
end
