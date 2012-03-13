class Speciality < ActiveRecord::Base
  belongs_to :department
  has_many :groups
  has_many :teaching_plans
  
  validates_presence_of :department
  
  def to_label
    "#{name} (#{code})"
  end

protected

  def authorized_for_update?
    return true unless current_user
    self.department_id == current_user.department_id
  end

  def authorized_for_delete?
    return true unless current_user
    self.department_id == current_user.department_id
  end

end
