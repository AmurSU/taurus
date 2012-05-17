class Pair < ActiveRecord::Base
  belongs_to :charge_card
  belongs_to :classroom
  has_many :subgroups, :dependent => :destroy

  accepts_nested_attributes_for :subgroups

  validate :create_validation, :on => :create
  validate :update_validation, :on => :update
  validate :expiration_date_validness, :activation_date_validness
  validate :week_number_existance

  scope :in_semester, lambda { |semester| where('("pairs"."expired_at" >= ? AND "pairs"."expired_at" <= ?) OR ("pairs"."active_at" >= ? AND "pairs"."active_at" <= ?)', semester.start, semester.end, semester.start, semester.end) }

  def in_semester?(semester)
    (active_at >= semester.start and active_at <= semester.end) or (expired_at >= semester.start and expired_at <= semester.end)
  end

  def name
    [lecturer, full_discipline, "ауд: #{classroom.try(:full_name)}", timeslot, groups_string].compact.select{ |e| e != ''}.join(', ')
  end

  def timeslot
    str = [Timetable.days[day_of_the_week - 1], pair_number.to_s + '-я пара', week_string].join(', ')
    str == '' ? '' : 'окно: ' + str
  end
  
  def week_string
    week == 0 ? 'обе недели' : week.to_s + '-я неделя'
  end
  
  def lecturer
    name = self.try(:charge_card).try(:teaching_place).try(:lecturer).try(:name) || ''
    apart = name.split(' ')
    name = apart[0]
    name += (' ' + apart[1].slice(/^./) + '.') if apart[1]
    name += (apart[2].slice(/^./) + '.') if apart[2]
    name
  end

  def lecturer_full
    self.try(:charge_card).try(:teaching_place).try(:name)
  end

  def lecturer_id
    self.try(:charge_card).try(:teaching_place).try(:lecturer).try(:id) || nil
  end

  def assistant
    name = self.try(:charge_card).try(:assistant_teaching_place).try(:lecturer).try(:name) || ''
    apart = name.split(' ')
    name = apart[0]
    name += (' ' + apart[1].slice(/^./) + '.') if apart[1]
    name += (apart[2].slice(/^./) + '.') if apart[2]
    name
  end

  def assistant_full
    self.try(:charge_card).try(:assistant_teaching_place).try(:name)
  end

  def assistant_id
    self.try(:charge_card).try(:assistant_teaching_place).try(:lecturer).try(:id) || nil
  end

  def full_discipline
    full = self.try(:charge_card).try(:discipline).try(:name)
    unless (lesson = self.try(:charge_card).try(:lesson_type).try(:name)).nil?
      full += ' (' + lesson + ')'
    end
    full || ''
  end

  def discipline
    self.try(:charge_card).try(:discipline).try(:name)
  end

  def short_discipline
    self.try(:charge_card).try(:discipline).try(:short_name)
  end

  def groups
    unless charge_card.nil?
      groups = charge_card.groups
    end
    groups || []
  end
  
  def groups_string
    g = groups.map do |g|
      name = g.name.to_s 
      if (number = g.subgroups.find_by_pair_id(id).try(:number) || 0) == 0
        subgroup = ''
      else
        subgroup = ' (' + number.to_s + '-я подгруппа)'
      end
      name + subgroup
    end
    g.join(', ') == '' ? '' : 'группы: ' + g.join(', ')
  end

  def lesson_type
    self.try(:charge_card).try(:lesson_type).try(:name)
  end
  
  def max_subgroups
    self.charge_card.jets.max_by { |jet| jet.subgroups_quantity }.subgroups_quantity
  end
  
  private
  
  def create_validation
    conditions = { :classroom_id => classroom_id,
                   :day_of_the_week => day_of_the_week,
                   :pair_number => pair_number,
                   :week => [ 0, week ] }
    if (conflicts = Pair.all(:conditions => conditions)).size > 0
      pairs = conflicts.map { |p| p.name }.join('<br />')
      errors[:base] << "Невозможно создать пару, так как следующая пара:<br /><br />" +
      pairs +
      "<br /><br />уже существует в этом временном окне этой аудитории."
    end
  end
  
  def update_validation
    week_conditions = week == 0 ? [0, 1, 2] : [0, week]
    conditions = ['pairs.id <> ? AND pairs.day_of_the_week = ? AND pairs.pair_number = ? AND pairs.week IN (?) AND NOT ((pairs.active_at > ? AND expired_at > ?) OR (active_at < ? AND expired_at < ?))',
                  id, day_of_the_week, pair_number, week_conditions, expired_at, expired_at, active_at, active_at]
    if (candidates = Pair.all(:conditions => conditions)).size > 0
      # classroom busyness (it's okay if there is no classroom yet)
      unless classroom_id.nil?
        if (conflicts = candidates.select { |c| c.classroom_id == classroom.id }).size > 0
          pairs = conflicts.map { |p| p.name }.join('<br />')
          errors[:base] << "Невозможно сохранить пару, так как следующие пары:<br /><br />" +
          pairs +
          "<br /><br />уже существуют в этом временном окне этой аудитории."
          candidates -= conflicts 
        end
      end
      # lecturer busyness
      if (conflicts = candidates.select { |c| 
            c.charge_card && charge_card && 
            (c.charge_card.teaching_place.lecturer == charge_card.teaching_place.lecturer ||
             c.charge_card.try(:assistant_teaching_place).try(:lecturer) == charge_card.teaching_place.lecturer)
      }).size > 0
        pairs = conflicts.map { |p| p.name }.join('<br />')
        errors[:base] << "Невозможно сохранить пару, так как этот преподаватель уже ведет следующие пары:<br /><br />" +
        pairs +
        "<br /><br />в этом временном окне."
        candidates -= conflicts
      end
      # assistant lecturer busyness
      if (charge_card.try(:assistant_teaching_place).try(:lecturer) != nil)
        if (conflicts = candidates.select { |c| 
            c.charge_card && charge_card && 
            (c.charge_card.teaching_place.lecturer == charge_card.try(:assistant_teaching_place).try(:lecturer) ||
             c.charge_card.try(:assistant_teaching_place).try(:lecturer) == charge_card.try(:assistant_teaching_place).try(:lecturer))            
        }).size > 0
          pairs = conflicts.map { |p| p.name }.join('<br />')
          errors[:base] << "Невозможно сохранить пару, так как ассистирующий преподаватель уже ведет следующие пары:<br /><br />" +
          pairs +
          "<br /><br />в этом временном окне."
          candidates -= conflicts
        end
      end
      # subgroups busyness
      if (conflicts = candidates.select { |c| c.charge_card && charge_card && (c.charge_card.groups & charge_card.groups).size > 0 }).size > 0
        groups_intersect = conflicts.map { |c| [c, c.charge_card.groups & charge_card.groups] }
        conflicts = []
        groups_intersect.each do |intersect|
          intersect[1].each do |group|
            pair = subgroups.select { |s| group.jets.map { |j| j.id }.include?(s.jet_id) }.first
            candidate = group.subgroups.find_by_pair_id(intersect[0].id)
            if pair && candidate && (pair.number == 0 || candidate.number == 0 || pair.number == candidate.number)
              conflicts << intersect[0]
            end
          end
        end
        if conflicts.size > 0
          pairs = conflicts.map { |p| p.name }.join('<br />')
          errors[:base] << "Невозможно сохранить пару, так как у одной или нескольких групп существуют следующие пары:<br /><br />" +
          pairs +
          "<br /><br />в этом временном окне."
          candidates -= conflicts
        end
      end
    end
  end
  
  def activation_date_validness
    errors[:base] << "Дата начала ведения данной пары должна быть установлена!" if active_at.blank?
  end

  def expiration_date_validness
    errors[:base] << "Дата окончания ведения данной пары должна быть установлена!" if expired_at.blank?
  end

  def week_number_existance
    errors[:base] << "Номер недели должен быть указан" unless (0..2).include? week
  end

end
