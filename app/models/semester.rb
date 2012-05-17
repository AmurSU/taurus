class Semester < ActiveRecord::Base
  has_many :charge_cards, :dependent => :destroy

  validates :full_time, :inclusion => { :in => [true, false] }
  validates :open, :inclusion => { :in => [true, false] }
  validates :number, :presence => true,
                     :uniqueness   => { :scope => [:year, :full_time] },
                     :numericality => { :only_integer => true },
                     :inclusion => { :in => [1, 2] }
  validates :year, :presence => true,
                   :numericality => { :only_integer => true,
                                      :greater_than => 2000,
                                      :less_than    => 2100 }
  validates :start, :presence => true
  validates :end, :presence => true
  validates_date :start, :before => :end
  validates_date :end, :after => :start

  scope :sorted, order('"semesters"."year" DESC, "semesters"."number" DESC, "semesters"."full_time" DESC')
  default_scope where(:open => true).sorted

  def to_label
    "#{academic_year} #{number}-й #{full_time ? 'очный' : 'заочный' } семестр"
  end

  def to_s
    to_label
  end

  def academic_year
    "#{year}/#{year+1}"
  end

  def charge_card_count
    charge_cards.count
  end

end
