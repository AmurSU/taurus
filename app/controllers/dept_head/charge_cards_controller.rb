class DeptHead::ChargeCardsController < DeptHead::BaseController
  active_scaffold do |config|
    config.actions << :delete
    config.columns = [:semester, :teaching_place, :assistant_teaching_place, :lesson_type, :jets, :discipline, :hours_quantity, :hours_per_week, :weeks_quantity, :groups]
    config.create.columns.exclude :groups, :hours_quantity
    config.update.columns.exclude :groups, :hours_quantity
    config.list.columns.exclude :jets
    config.columns[:semester].form_ui = :select
    config.columns[:semester].inplace_edit = true
    config.columns[:discipline].form_ui = :record_select
    config.columns[:lesson_type].form_ui = :select
    config.columns[:lesson_type].inplace_edit = true
    config.columns[:teaching_place].form_ui = :select
    config.columns[:teaching_place].clear_link
    config.columns[:teaching_place].inplace_edit = true
    config.columns[:assistant_teaching_place].form_ui = :select
    config.columns[:assistant_teaching_place].clear_link
    config.columns[:assistant_teaching_place].inplace_edit = true
    config.columns[:discipline].clear_link
    config.columns[:groups].clear_link
    config.columns[:hours_per_week].inplace_edit = true
    config.columns[:weeks_quantity].inplace_edit = true
  end

  def conditions_for_collection
    {:semester_id => current_semester.id}
  end

protected

  def do_new
      super
      @record.semester = current_semester
  end

end
