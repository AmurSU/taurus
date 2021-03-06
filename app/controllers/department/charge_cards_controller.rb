# -*- encoding : utf-8 -*-
class Department::ChargeCardsController < Department::BaseController
  active_scaffold do |config|
    config.actions << :delete
    config.columns = [:semester, :teaching_place, :assistant_teaching_place, :lesson_type, :jets, :disciplines, :hours_quantity, :hours_per_week, :weeks_quantity, :groups, :preferred_classrooms, :note]
    config.create.columns.exclude :groups, :hours_quantity
    config.update.columns.exclude :groups, :hours_quantity
    config.list.columns.exclude :jets
    config.columns[:semester].form_ui = :select
    config.columns[:semester].inplace_edit = true
    config.columns[:disciplines].form_ui = :record_select
    config.columns[:disciplines].clear_link
    config.columns[:lesson_type].form_ui = :select
    config.columns[:lesson_type].inplace_edit = true
    config.columns[:teaching_place].form_ui = :select
    config.columns[:teaching_place].clear_link
    config.columns[:teaching_place].inplace_edit = true
    config.columns[:assistant_teaching_place].form_ui = :select
    config.columns[:assistant_teaching_place].clear_link
    config.columns[:assistant_teaching_place].inplace_edit = true
    config.columns[:groups].clear_link
    config.columns[:hours_per_week].inplace_edit = true
    config.columns[:weeks_quantity].inplace_edit = true
    config.columns[:note].inplace_edit = true
  end

  def conditions_for_collection
    {:semester_id => current_semester.id}
  end

protected

  def do_new
      super
      @record.semester = current_semester
  end

  # It's a hack, that allows to change groups in charge card edit.
  # TODO: Remove it after bugfix in active_scaffold 
  def before_update_save(record)
    record.preferred_classroom_ids = params[:record][:preferred_classrooms] if params[:record]
    record.instance_variable_set("@readonly", false) # Very dirty hack (AS and CanCan)
    record.jets.each do |jet|
      jet.save if jet.group_id_changed? or jet.subgroups_quantity_changed?
    end
  end

end
