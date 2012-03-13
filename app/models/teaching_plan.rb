class TeachingPlan < ActiveRecord::Base
  belongs_to :speciality
  belongs_to :discipline

  validates_presence_of :speciality_id, :discipline_id, :course, :semester
  validates_numericality_of :course, :semester
  validates_numericality_of :lections, :practics, :lab_works, :allow_nil => true
  validates_inclusion_of :semester, :in => [1, 2]

  def create_charge_cards_for(groups)
    created = []
    if self.lections
      card = ChargeCard.for_autocreation(self.discipline_id, 1, groups)
      card.weeks_quantity = 18
      card.hours_per_week = self.lections / 18
      if card.save
        created << card
        card.groups = groups unless card.groups == groups
      end
    end
    if self.practics
      groups.each do |group|
        card = ChargeCard.for_autocreation(self.discipline_id, 2, group)
        card.weeks_quantity = 18
        card.hours_per_week = self.practics / 18
        if card.save
          created << card
          card.groups = [group] unless card.groups == [group]
        end
      end
    end
    if self.lab_works
      groups.each do |group|
        card = ChargeCard.for_autocreation(self.discipline_id, 3, group)
        card.weeks_quantity = 18
        card.hours_per_week = self.lab_works / 18
        if card.save
          created << card
          card.groups = [group] unless card.groups == [group]
        end
      end
    end
    return created
  end

end
