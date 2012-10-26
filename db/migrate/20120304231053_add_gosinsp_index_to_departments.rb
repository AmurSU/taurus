class AddGosinspIndexToDepartments < ActiveRecord::Migration
  def self.up
    add_column :departments, :gosinsp_code, :integer
    
    amursu_depts = [
      "Автоматизации производственных процессов и электротехники",
      "Энергетики",
      "Иностранных языков №2",
      "Китаеведения",
      "Всемирной истории и международных отношений",
      "Информационных и управляющих систем",
      "Математического анализа и моделирования",
      "Общей математики и информатики",
      "Гражданского права",
      "Уголовного права",
      "Конституционного права",
      "Теории и истории государства и права",
      "Теоретической и экспериментальной физики",
      "Безопасности жизнедеятельности",
      "Химии и естествознания",
      "Физического материаловедения и лазерных технологий",
      "Социологии",
      "Религиоведения",
      "Психологии и педагогики",
      "Медико-социальной работы",
      "Физической культуры",
      "Философии",
      "Русского языка",
      "Немецкой филологии и перевода",
      "Иностранных языков №1",
      "Журналистики",
      "Английской филологии и перевода",
      "Конструирования и технологии одежды",
      "Дизайна",
      "Рисунка и живописи",
      "Финансов",
      "Экономической теории и государственного управления",      
      "Мировой экономики, таможенного дела и туризма",
      "Экономики и менеджмента организации",
      "Коммерции и товароведения",
      "Геологии и природопользования",
      "Литературы и мировой художественной культуры"
    ]

    amursu_depts.each_with_index do |dept_name, index|
      dept = Department.find_by_name(dept_name)
      if dept
        dept.gosinsp_code = index+1
        dept.save
      end
    end
  end

  def self.down
    remove_column :departments, :gosinsp_code
  end
end
