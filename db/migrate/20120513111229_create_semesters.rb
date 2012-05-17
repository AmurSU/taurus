class CreateSemesters < ActiveRecord::Migration

  def up
    create_table :semesters do |t|
      t.integer :year, :null => false
      t.integer :number, :null => false
      t.boolean :full_time, :default => true, :null => false
      t.date :start
      t.date :end
      t.boolean :open, :default => false, :null => false
      t.boolean :freezed, :default => false, :null => false
      t.timestamps
    end
    add_index :semesters, [:year, :number, :full_time], :unique => true

    change_table :charge_cards do |t|
      t.references :semester
    end

    say_with_time "Create initial semester and make all charge cards belong to it." do
      year = Date.today.year - (Date.today.month < 6 ? 1 : 0)
      number = Date.today.month < 6 ? 2 : 1
      semester = Semester.create!(:year => year, :number => number, :full_time => true, :open => true)
      execute "UPDATE charge_cards SET semester_id = #{semester.id}"
    end
  end
  
  def down
    change_table :charge_cards do |t|
      t.remove_references :semester
    end
    remove_index :semesters, [:year, :number, :full_time]
    drop_table :semesters
  end

end
