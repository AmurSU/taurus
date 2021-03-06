# -*- encoding : utf-8 -*-
class Supervisor::ClassroomsController < Supervisor::BaseController
  active_scaffold do |config|
    config.actions << :delete
    config.columns = [:building, :name, :title, :department, :department_lock, :capacity, :properties]
    config.columns[:building].form_ui = :select
    config.columns[:department].form_ui = :select
    config.columns[:department_lock].form_ui = :checkbox
    config.columns[:building].clear_link
    config.columns[:department].clear_link
  end

  def before_update_save(record)
    record[:properties] = params[:record][:properties]
  end

end
