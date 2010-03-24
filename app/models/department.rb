class Department < ActiveRecord::Base
  belongs_to :faculty
  has_many :teaching_places, :dependent => :destroy
  has_many :lecturers, :through => :teaching_places

  acts_as_chainable :from => :faculty, :select_label => 'Кафедра'
end
