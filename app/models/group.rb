class Group < ActiveRecord::Base
  belongs_to :speciality
  has_many :jets, :dependent => :destroy
  has_many :subgroups, :through => :jets
  has_many :charge_cards, :through => :jets

  validates_presence_of :name, :forming_year
  validates_uniqueness_of :name, :scope => :forming_year
  validates_format_of :forming_year, :with => /^(20)\d{2}$/,
    :message => '- необходимо вводить год целиком. Допустимы годы от 2000 до 2099'

  named_scope :for_timetable, :include => [{:subgroups => [{:pair => [{:classroom => :building}, { :charge_card => [:discipline, {:teaching_place => [:lecturer, :department]}]}]}]}]
  named_scope :by_name, lambda { |name| { :conditions => ['groups.name LIKE ?', escape_name(name)] } }
  named_scope :for_groups_editor, :include => {:jets => {:subgroups => {:pair => [{:classroom => :building}, { :charge_card => [:discipline, {:teaching_place => [:lecturer, :department]}]}]}}}

  def course
    this_year = Time.now.year.to_i
    course = this_year - forming_year
    course += 1 if forming_year <= this_year and Time.now.month.to_i >= 7
    course = '(1)' if forming_year > this_year or (forming_year == this_year and Time.now.month.to_i < 7)
    return course
  end

  def get_pairs
    days = Timetable.days
    times = Timetable.times
    weeks = Timetable.weeks
    pairs_array = Array.new(days.size).map!{Array.new(times.size).map!{Array.new(weeks.size + 1).map!{Array.new}}}
    subgroups.each do |subgroup|
      pair = subgroup.pair
      pairs_array[pair.day_of_the_week - 1][pair.pair_number - 1][pair.week] << [pair, subgroup.number]
    end
    pairs_array
  end

  def pairs_with_subgroups
    self.subgroups.all(:include => :pair).map{|s| [s.pair, s.number]}
  end

  def pairs_with_subgroups_for_timeslot(day, time)
    subgroups = self.subgroups.all :joins => :pair, :include => :pair, 
      :conditions => {:pairs => {
        :day_of_the_week => day, :pair_number => time
      }}
    return subgroups.map{|s| [s.pair, s.number]}
  end

  def department
    Department.first :joins => {:specialities => :groups}, :conditions => {:groups => {:id => self.id}}
  end

  def descriptive_name
    "#{name} #{department ? "(#{department.short_name})" : ""} #{population ? " — #{population} чел." : ""}"
  end

  private

  def self.escape_name(name)
    name.to_s.gsub('%', '\%').gsub('_', '\_') + '%'
  end

  protected

  def authorized_for_update?
    return true unless current_user
    self.speciality.try(:department_id) == current_user.department_id
  end

  def authorized_for_delete?
    return true unless current_user
    self.speciality.try(:department_id) == current_user.department_id
  end

end

