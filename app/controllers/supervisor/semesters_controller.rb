class Supervisor::SemestersController < ApplicationController
  active_scaffold :semester do |conf|
    conf.actions << :delete
    conf.list.columns = [:academic_year, :year, :number, :full_time, :start, :end, :open, :charge_card_count]
    conf.create.columns = [:year, :number, :full_time, :start, :end, :open]
    conf.update.columns = [:year, :number, :full_time, :start, :end, :open]
    conf.columns[:full_time].form_ui = :checkbox
    conf.columns[:open].form_ui = :checkbox
  end

  def beginning_of_chain
    super.unscoped.sorted
  end

end 
