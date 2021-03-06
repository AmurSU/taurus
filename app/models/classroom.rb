# -*- encoding : utf-8 -*-
class Classroom < ActiveRecord::Base
  has_many :pairs, :dependent => :nullify
  belongs_to :building
  belongs_to :department
  has_and_belongs_to_many :recommended_charge_cards, class_name: "ChargeCard", join_table: "charge_cards_preferred_classrooms"

  serialize :properties, ActiveRecord::Coders::Hstore

  validates :name, :presence => true, :uniqueness => {:scope => :building_id}

  default_scope includes(:building).order("classrooms.name ASC, buildings.name ASC").joins(:building)

  def self.all_with_recommended_first_for (department)
    if department.class == Department
      classrooms = find_by_sql("(
        SELECT classrooms.*
        FROM classrooms JOIN buildings ON classrooms.building_id = buildings.id
        WHERE classrooms.department_id = #{department.id}
        ORDER BY
	        classrooms.department_lock DESC NULLS LAST,
	        classrooms.name ASC,
	        buildings.name ASC
        ) UNION ALL (
        SELECT classrooms.*
        FROM classrooms JOIN buildings ON classrooms.building_id = buildings.id
        WHERE classrooms.department_id <> #{department.id} OR classrooms.department_id IS NULL
        ORDER BY
	        classrooms.name ASC,
	        buildings.name ASC
      )").each do |c|
        c.set_recommended_dept(department)
      end
      includes = [:department, :building, :recommended_charge_cards]
      ActiveRecord::Associations::Preloader.new(classrooms, includes).run
      classrooms
    else
      all
    end
  end

  def full_name
    "#{short_name}#{': '+self.title if self.title}"
  end

  def short_name
    "#{self.name}#{' ('+self.building.name+')' if self.building}"
  end

  alias to_label full_name

  def descriptive_name
    dept = "Кафедра #{self.department.short_name}." if self.department
    cap = self.capacity ? "#{self.capacity} человек" : "Вместимость не указана"
    "#{self.full_name}.	#{cap}#{", #{properties_human}" unless properties_human.blank?}. #{dept}"
  end

  def set_recommended_dept(dept)
    @recommended_dept = dept if dept.class == Department
  end

  attr_accessor :current_charge_card_id

  def name_with_recommendation
    recommended = self.department_id == @recommended_dept.try(:id) && self.department_lock
    preferred = recommended_charge_card_ids.include? current_charge_card_id
    "#{descriptive_name} #{"(предпочтительно)" if preferred} #{"(рекомендуется)" if recommended}"
  end

  def properties_human
    props_string = I18n.t('activerecord.attributes.classroom.property').keys.map do |key|
      if (self.properties or {})[key.to_s]
        I18n.t("activerecord.attributes.classroom.property.#{key}")
      end
    end.compact.join(", ")
    Unicode::downcase(props_string)
  end
end
