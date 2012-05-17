class Group < ActiveRecord::Base
  belongs_to :speciality
  has_many :jets, :dependent => :destroy
  has_many :subgroups, :through => :jets
  has_many :charge_cards, :through => :jets

  validates_presence_of :name, :forming_year
  validates_uniqueness_of :name, :scope => :forming_year
  validates_format_of :forming_year, :with => /^(20)\d{2}$/,
    :message => '- необходимо вводить год целиком. Допустимы годы от 2000 до 2099'

  scope :for_timetable, includes(:subgroups => [{:pair => [{:classroom => :building}, { :charge_card => [:discipline, {:teaching_place => [:lecturer, :department]}]}]}])
  scope :by_name, lambda { |name| where('groups.name ILIKE ?', escape_name(name)) }
  scope :for_groups_editor, includes(:jets => {:subgroups => {:pair => [{:classroom => :building}, { :charge_card => [:discipline, {:teaching_place => [:lecturer, :department]}]}]}})

  cattr_accessor :current_semester

  def course
    this_year = current_semester.nil?? Time.now.year.to_i : current_semester.year
    course = this_year - forming_year + 1
    unless current_semester
      course -= 1 if Time.now.month.to_i < 8
    end
    course = '[1]' if course < 1
    return course
  end

  def course_in(semester)
    semester.year - forming_year + 1
  end

  def get_pairs(semester)
    days = Timetable.days
    times = Timetable.times
    weeks = Timetable.weeks
    pairs_array = Array.new(days.size).map!{Array.new(times.size).map!{Array.new(weeks.size + 1).map!{Array.new}}}
    subgroups.each do |subgroup|
      pair = subgroup.pair
      pairs_array[pair.day_of_the_week - 1][pair.pair_number - 1][pair.week] << [pair, subgroup.number] if pair.in_semester?(semester)
    end
    pairs_array
  end

  def pairs_with_subgroups
    self.subgroups.includes(:pair).map{|s| [s.pair, s.number]}
  end

  def pairs_with_subgroups_for_timeslot(day, time, semester)
    subgroups = self.subgroups.joins(:pair).includes(:pair).where(:pairs => {
        :day_of_the_week => day, :pair_number => time,
      }).where('("pairs"."expired_at" >= ? AND "pairs"."expired_at" <= ?) OR ("pairs"."active_at" >= ? AND "pairs"."active_at" <= ?)', semester.start, semester.end, semester.start, semester.end)
    return subgroups.map{|s| [s.pair, s.number]}
  end

  def department
    Department.joins(:specialities => :groups).where(:groups => {:id => self.id}).first
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

